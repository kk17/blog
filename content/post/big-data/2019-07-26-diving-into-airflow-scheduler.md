---
title: "Diving Into Airflow Scheduler"
slug: "diving-into-airflow-scheduler"
date: 2019-07-26T10:02:55+08:00
lastmod: 2019-07-26T10:02:55+08:00
draft: false
keywords: ["airflow"]
description: "airflow scheduler"
tags: ["airflow"]
categories: ["big-data"]
author: "Kyle"

# You can also close(false) or open(true) something for this content.
# P.S. comment can only be closed
comment: true
toc: true
autoCollapseToc: false
# You can also define another contentCopyright. e.g. contentCopyright: "This is another copyright."
contentCopyright: false
reward: false
mathjax: false
---

[Last article](../understand-airflow) we told about the basic concepts and architecture of Airflow, and we knew that Airflow has three major components:  `webserver`,  `scheduler` and `executor.`  This article will talk about the detail of the `scheduler` by diving into some of the source code(version: 1.10.1).

<!--more-->

## Key Concept

We already told about the key concepts of Airflow, let's recap some concepts use in airflow scheduler here.

- Dag Files: Python files that could contain DAGs. A DAG can be definite in a single python file or in multiple python files packaged into an egg file.
- Dag (Directed Acyclic Graph): a workflow which glues all the tasks with inter-dependencies.
- Task: a parameterized instance of an operator/sensor which represents a unit of actual work to be executed.
- DagRun:  an object representing an instantiation of the DAG in time.
- TaskInstance: an object representing an instantiation of the Task in time.
- DagBag: a collection of dags, parsed out of a folder tree and has high
level configuration settings, like what database to use as a backend and
what executor to use to fire off tasks.
- Job: Jobs are processing items with state
and duration that aren't task instances. There are three types of job in Airflow: ScheduleJob, LocalTaskJob, and BackfillJob.

## Process Loop

The Airflow scheduler is designed to run as a persistent service in an Airflow production environment. To kick it off, all you need to do is execute `airflow scheduler` command. Let's look at how Airflow parses this command and start the process loop.

![process_loop_outer](/process_loop_outer/process_loop_outer.svg)

Firstly, airflow use `argparse` to parse the command and invoke the `scheduler` function in `airflow.bin.cli`. And then `scheduler` function creates a ScheduleJob and run its `run` method. The ScheduleJob will save itself to the database, start the executor and create a `DagFileProcessorManager`. Eventually, the ScheduleJob will run a loop to invoke the `processor_manager periodically .heartbeat` method.

All the daemon service of Airflow are started by running `airflow {serve_name}` command. Basically, the `airflow` command is a python command-line script. We can look at the source code to know how it starts the service.

[airflow/bin/airflow](https://github.com/apache/airflow/blob/1.10.1/airflow/bin/airflow#L20)

```python
from airflow.bin.cli import CLIFactory

if __name__ == '__main__':
    parser = CLIFactory.get_parser()
    args = parser.parse_args()
    args.func(args)
```

[airflow/bin/cli.py#CLIFactory](https://github.com/apache/airflow/blob/1.10.1/airflow/bin/cli.py#L1247)

```python
class CLIFactory(object):
    args = {
        'dag_id': Arg(("dag_id",), "The id of the dag"),
        'task_id': Arg(("task_id",), "The id of the task"),
        ...
    },
    subparsers = (
      ...
      {
          'func': scheduler,
          'help': "Start a scheduler instance",
          'args': ('dag_id_opt', 'subdir', 'run_duration', 'num_runs',
                   'do_pickle', 'pid', 'daemon', 'stdout', 'stderr',
                   'log_file'),
      },
      ...
    )
    subparsers_dict = {sp['func'].__name__: sp for sp in subparsers}
    dag_subparsers = (
        'list_tasks', 'backfill', 'test', 'run', 'pause', 'unpause')
```

There are two important mappings in the `CLIFactory`, `args` maps the command line arguments to some default value and help information. `subparsers_dict` maps the subcommand to objective python function.

[airflow/bin/cli.py#scheduler](https://github.com/apache/airflow/blob/1.10.1/airflow/bin/cli.py#L903)

```python
@cli_utils.action_logging
def scheduler(args):
    print(settings.HEADER)
    job = jobs.SchedulerJob(
        dag_id=args.dag_id,
        subdir=process_subdir(args.subdir),
        run_duration=args.run_duration,
        num_runs=args.num_runs,
        do_pickle=args.do_pickle)

    if args.daemon:
        pid, stdout, stderr, log_file = setup_locations("scheduler",
        ...
        ctx = daemon.DaemonContext(
        ...
        with ctx:
            job.run()
        ...
    else:
        ...
        job.run()
```

[airflow/jobs.py#ScheduleJob.run](https://github.com/apache/airflow/blob/1.10.1/airflow/jobs.py#L191)

```python
  def run(self):
    Stats.incr(self.__class__.__name__.lower() + '_start', 1, 1)
    # Adding an entry in the DB
    with create_session() as session:
        self.state = State.RUNNING
        session.add(self)
        session.commit()
        ...
        try:
            self._execute()
            # In case of max runs or max duration
            self.state = State.SUCCESS
        except SystemExit as e:
        ...
        finally:
            self.end_date = timezone.utcnow()
            session.merge(self)
            session.commit()
  def _execute(self):
    raise NotImplementedError("This method needs to be overridden")
```

We can know that the scheduler service is actually an `airflow.jobs.SchedulerJob` instance that runs its `run` method. It will add itself into the database `job` table and then run the `_execute` helper method handling some and normal exit situations. Now let us look at the `_execute` method.

[airflow/jobs.py#ScheduleJob._execute](https://github.com/apache/airflow/blob/1.10.1/airflow/jobs.py#L1544)

```python
def _execute(self):
    # Use multiple processes to parse and generate tasks for the
    # DAGs in parallel. By processing them in separate processes,
    # we can get parallelism and isolation from potentially harmful
    # user code.

    # Build up a list of Python files that could contain DAGs
    known_file_paths = list_py_file_paths(self.subdir)

    processor_manager = DagFileProcessorManager(self.subdir,
                                                known_file_paths,
                                                self.max_threads,
                                                self.file_process_interval,
                                                self.file_process_interval,
                                                processor_factory)

    try:
        self._execute_helper(processor_manager)
    finally:
        self.log.info("Exited execute loop")

        # Kill all child processes on exit since we don't want to leave
        # them as orphaned.
        pids_to_kill = processor_manager.get_all_pids()
        ...
```

We can see that `_execute` method create a `processor_manager` and the `processor_manager` use `processor_factory` to create a processor for each dag file_path. We can also find out it uses configurations which configured in the `airflow.cfg` file.

```python
file_process_interval=conf.getint('scheduler', 'min_file_process_interval'),
self.heartrate = conf.getint('scheduler', 'SCHEDULER_HEARTBEAT_SEC')
self.max_threads = conf.getint('scheduler', 'max_threads')

# How often to scan the DAGs directory for new files. Default to 5 minutes.
self.dag_dir_list_interval = conf.getint('scheduler', 'dag_dir_list_interval')
# How often to print out DAG file processing stats to the log. Default to
# 30 seconds.
self.print_stats_interval = conf.getint('scheduler', 'print_stats_interval')
# Parse and schedule each file no faster than this interval. Default
# to 3 minutes.
self.file_process_interval = file_process_interval

self.max_tis_per_query = conf.getint('scheduler', 'max_tis_per_query')
if run_duration is None:
    self.run_duration = conf.getint('scheduler', 'run_duration')
```

Then the `_execute` method run the `_execute_helper` method.

[airflow/jobs.py#ScheduleJob._execute_helper](https://github.com/apache/airflow/blob/1.10.1/a.irflow/jobs.py#L1627)

``` python
def _execute_helper(self, processor_manager):
    self.executor.start()

    ## self.log.info("Resetting orphaned tasks for active dag runs")
    self.reset_state_for_orphaned_tasks()

    execute_start_time = timezone.utcnow()

    # Use this value initially
    known_file_paths = processor_manager.file_paths


    # For the execute duration, parse and schedule DAGs
    while (timezone.utcnow() - execute_start_time).total_seconds() <    self.run_duration or self.run_duration < 0:
        self.log.debug("Starting Loop...")

        if elapsed_time_since_refresh > self.dag_dir_list_interval:
                    # Build up a list of Python files that could contain DAGs
                    known_file_paths = list_py_file_paths(self.subdir)
                    last_dag_dir_refresh_time = timezone.utcnow()
                    processor_manager.set_file_paths(known_file_paths)
                    self.clear_nonexistent_import_errors    (known_file_paths=known_file_paths)

        simple_dags = processor_manager.heartbeat()
```

The `_execute_helper` starts the `executor` and run the `processor_manager.heartbeat()` in a loop with the configured `dag_dir_list_interval`.

## DagFileProcessorManager Heartbeat

As fast as we know, the `processor_manager.heartbeat` is the most important method in the process loop, so let's dive into it.

![process_loop_inner](/process_loop_inner/process_loop_inner.svg)

The `processor_manager` actually maintains a list of DagFileProcessor(*don't know how to present this list in the UML sequence diagram*) to process the dag files. The max size of the processor list is configured in the `airflow.cfg` -> `scheduler`-> `max_threads`. In the `heartbeat` method, the `processor_manager.heartbeat` kick off new `DagFileProcessor` and `DagFileProcessor` kick off new `multiprocessing. Process` to process DAG definition files and read the results from the finished processors. One process corresponds to one `SchedulerJob` instance. When the process started, it use `scheduler_job.process_file` method to process the DAG files and stores the result into a queue. The `processor_manager` collects all the results that were produced by processors that have finished since the last time this was called. it also starts more processors if necessary.

[airflow/utils/dag_processing.py#DagFileProcessorManager.heartbeat](https://github.com/apache/airflow/blob/1.10.1/airflow/utils/dag_processing.py#L473)

```python
def heartbeat(self):
    # get finished_processors and running_processors
    finished_processors = {}
    running_processors = {}
    for file_path, processor in self._processors.items():
        if processor.done:
            ...
            finished_processors[file_path] = processor
            ...
        else:
            running_processors[file_path] = processor
    self._processors = running_processors

    # Collect all the DAGs that were found in the processed files
    simple_dags = []
    for file_path, processor in finished_processors.items():
        if processor.result is None:
            ...
        else:
            for simple_dag in processor.result:
                simple_dags.append(simple_dag)

    # Generate more file paths to process if we processed all the files
    # already.
    ...
    # Start more processors if we have enough slots and files to process
    while (self._parallelism - len(self._processors) > 0 and len    (self._file_path_queue) > 0):
        file_path = self._file_path_queue.pop(0)
        processor = self._processor_factory(file_path)

        processor.start()
        self._processors[file_path] = processor
    # Update scheduler heartbeat count.
    ...
    return simple_dags
```

[airflow/jobs.py#DagFileProcessor](https://github.com/apache/airflow/blob/1.10.1/airflow/jobs.py#L301)

```python
class DagFileProcessor(AbstractDagFileProcessor, LoggingMixin):
    ...
    def _launch_process(result_queue,...):
        ...
        def helper()
            scheduler_job = SchedulerJob(dag_ids=dag_id_white_list, log=log)
            result = scheduler_job.process_file(file_path, pickle_dags)
            result_queue.put(result)
        ...
        p = multiprocessing.Process(target=helper,
                                    args=(),
                                    name="{}-Process".format(thread_name))
        p.start()
        return p
    ...
    def start(self):
        """
        Launch the process and start processing the DAG.
        """
        self._process = DagFileProcessor._launch_process(
            self._result_queue,
            self.file_path,
            self._pickle_dags,
            self._dag_id_white_list,
            "DagFileProcessor{}".format(self._instance_id))
        self._start_time = timezone.utcnow()

```

## ScheduleJob Process File

Let's keep diving into the `scheduler_job.process_file` method.

![process_file](/process_file/process_file.svg)

The `scheduler_job.process_file` method first creates a `DagBag` instance for the dag file path. In the `DagBag` instance initiation, it loads the python modules in the file path using different std lib base on whether the path is a zip path.
After modules are loaded, `DagBag` collects all the DAGs in the modules.
ScheduleJob then gets all dags from `DagBag`, sync their states db and collect those dags which are not paused.

ScheduleJob iterates over all the un-paused dags and processes them. Processing includes:

1. Calculate `next_run_date` for dag and create appropriate `DagRun(s)` in the DB.
2. Create appropriate `TaskInstance(s)` in the DB for new `DagRuns`.
3. Find all active `DagRuns` for a dag and iterate over their unscheduled `TaskInstances`. If the dependencies of a `TaskInstance` is met, update the state of the `TaskInstance` to SCHEDULED.
4. Send emails for tasks that have missed SLAs.

[airflow/jobs.py#ScheduleJob.process_file](https://github.com/apache/airflow/blob/1.10.1/airflow/jobs.py#L1771)

```python
def process_file(self, file_path, pickle_dags=False, session=None):
    simple_dags = []

    try:
        dagbag = models.DagBag(file_path)
    except Exception:
        ...
        return []
    ...
    # Save individual DAGs in the ORM and update DagModel.last_scheduled_time
    for dag in dagbag.dags.values():
        dag.sync_to_db()

    paused_dag_ids = [dag.dag_id for dag in dagbag.dags.values() if dag.is_paused]

    # Pickle the DAGs (if necessary) and put them into a SimpleDag
    for dag_id in dagbag.dags:
        dag = dagbag.get_dag(dag_id)
        ...
        # Only return DAGs that are not paused
        if dag_id not in paused_dag_ids:
            simple_dags.append(SimpleDag(dag, pickle_id=pickle_id))

    if len(self.dag_ids) > 0:
        dags = [dag for dag in dagbag.dags.values()
                if dag.dag_id in self.dag_ids and
                dag.dag_id not in paused_dag_ids]
    else:
        dags = [dag for dag in dagbag.dags.values()
                if not dag.parent_dag and
                dag.dag_id not in paused_dag_ids]

    # Not using multiprocessing.Queue() since it's no longer a separate
    # process and due to some unusual behavior. (empty() incorrectly
    # returns true?)
    ti_keys_to_schedule = []
    self._process_dags(dagbag, dags, ti_keys_to_schedule)

    for ti_key in ti_keys_to_schedule:
        dag = dagbag.dags[ti_key[0]]
        task = dag.get_task(ti_key[1])
        # NOTE: create TaskInstance
        ti = models.TaskInstance(task, ti_key[2])
        ti.refresh_from_db(session=session, lock_for_update=True)
        ...
        dep_context = DepContext(deps=QUEUE_DEPS, ignore_task_deps=True)
        ...
        if ti.are_dependencies_met(
                dep_context=dep_context,
                session=session,
                verbose=True):
            # Task starts out in the scheduled state. All tasks in the
            # scheduled state will be sent to the executor
            ti.state = State.SCHEDULED

        # Also save this task instance to the DB.
        self.log.info("Creating / updating %s in ORM", ti)
        session.merge(ti)
    # commit batch
    session.commit()

    # Record import errors into the ORM
    ...
    # kill_zombies
    ...

    return simple_dags
```

[airflow/models/\_\_init\_\_.py#DagBag.process_file](https://github.com/apache/airflow/blob/1.10.1/airflow/models/__init__.py#L265)

```python
    def process_file(self, filepath, only_if_updated=True, safe_mode=True):
        ...
        mods = []
        is_zipfile = zipfile.is_zipfile(filepath)
        if not is_zipfile:
            ...
            org_mod_name, _ = os.path.splitext(os.path.split(filepath)[-1])
            mod_name = ...
            ...
            with timeout(configuration.conf.getint('core', "DAGBAG_IMPORT_TIMEOUT")):
                try:
                    m = imp.load_source(mod_name, filepath)
                    mods.append(m)
                except Exception as e:
                    ...
        else:
            zip_file = zipfile.ZipFile(filepath)
            for mod in zip_file.infolist():
                head, _ = os.path.split(mod.filename)
                mod_name, ext = os.path.splitext(mod.filename)
                if not head and (ext == '.py' or ext == '.pyc'):
                    ...
                    try:
                        sys.path.insert(0, filepath)
                        m = importlib.import_module(mod_name)
                        mods.append(m)
                    except Exception as e:
                        ...
        for m in mods:
            for dag in list(m.__dict__.values()):
                if isinstance(dag, DAG):
                    ...
                    try:
                        dag.is_subdag = False
                        self.bag_dag(dag, parent_dag=dag, root_dag=dag)
                        if isinstance(dag._schedule_interval, six.string_types):
                            croniter(dag._schedule_interval)
                        found_dags.append(dag)
                        found_dags += dag.subdags
                    except ...
        self.file_last_changed[filepath] = file_last_changed_on_disk
        return found_dags
```

[airflow/jobs.py#ScheduleJob._process_dags](https://github.com/apache/airflow/blob/1.10.1/airflow/jobs.py#L1398)

```python
def _process_dags(self, dagbag, dags, tis_out):
    for dag in dags:
        ...
        dag_run = self.create_dag_run(dag)
        if dag_run:
            self.log.info("Created %s", dag_run)
        self._process_task_instances(dag, tis_out)
        self.manage_slas(dag)

    models.DagStat.update([d.dag_id for d in dags])

```

[airflow/jobs.py#ScheduleJob.create_dag_run](https://github.com/apache/airflow/blob/1.10.1/airflow/jobs.py#L783)

```python
def create_dag_run(self, dag, session=None):
    """
    This method checks whether a new DagRun needs to be created
    for a DAG based on scheduling interval
    Returns DagRun if one is scheduled. Otherwise returns None.
    """
    if dag.schedule_interval:
        active_runs = DagRun.find(...)
        # return if already reached maximum active runs and no timeout setting
        if len(active_runs) >= dag.max_active_runs and not dag.dagrun_timeout:
            return
        timedout_runs = 0
        for dr in active_runs:
            if (dr.start_date and dag.dagrun_timeout and dr.start_date < timezone.utcnow() - dag.dagrun_timeout):
                dr.state = State.FAILED
                dr.end_date = timezone.utcnow()
                dag.handle_callback(dr, success=False, reason='dagrun_timeout',  dsession=session)
                timedout_runs += 1
        session.commit()
        if len(active_runs) - timedout_runs >= dag.max_active_runs:
            return

        # this query should be replaced by find dagrun
        last_scheduled_run = session.query(func.max(DagRun.execution_date)).filter_by(...).scalar()

        # don't schedule @once again
        if dag.schedule_interval == '@once' and last_scheduled_run:
            return None

        # don't do scheduler catchup for dag's that don't have dag.catchup = True
        if not (dag.catchup or dag.schedule_interval == '@once'):
            ...
            dag.start_date = ... # next_schedule_time_before_now

        next_run_date = None
        if not last_scheduled_run:
            # First run
            next_run_date = ... # minimal start_time of dag tasks
        else:
            next_run_date = dag.following_schedule(last_scheduled_run)

        # make sure backfills are also considered
        ...

        # don't ever schedule prior to the dag's start_date
        ...

        # don't ever schedule in the future
        ...

        # this structure is necessary to avoid a TypeError from concatenating
        # NoneType
        if dag.schedule_interval == '@once':
            period_end = next_run_date
        elif next_run_date:
            period_end = dag.following_schedule(next_run_date)

        # Don't schedule a dag beyond its end_date (as specified by the dag param)
        if next_run_date and dag.end_date and next_run_date > dag.end_date:
            return

        # Don't schedule a dag beyond its end_date (as specified by the task params)
        # Get the min task end date, which may come from the dag.default_args
        ...

        if next_run_date and period_end and period_end <= timezone.utcnow():
            # create a dagrun and save it to db
            next_run = dag.create_dagrun(
                run_id=DagRun.ID_PREFIX + next_run_date.isoformat(),
                execution_date=next_run_date,
                start_date=timezone.utcnow(),
                state=State.RUNNING,
                external_trigger=False
            )
            return next_run
```

[airflow/jobs.py##ScheduleJob._process_task_instances](https://github.com/apache/airflow/blob/1.10.1/airflow/jobs.py#L914)

```python
@provide_session
def _process_task_instances(self, dag, queue, session=None):
    """
    This method schedules the tasks for a single DAG by looking at the
    active DAG runs and adding task instances that should run to the
    queue.
    """

    # update the state of the previously active dag runs
    dag_runs = DagRun.find(dag_id=dag.dag_id, state=State.RUNNING, session=session)
    active_dag_runs = []
    for run in dag_runs:
        self.log.info("Examining DAG run %s", run)
        # don't consider runs that are executed in the future
        ...

        if len(active_dag_runs) >= dag.max_active_runs:
            self.log.info("Active dag runs > max_active_run.")
            continue

        # skip backfill dagruns for now as long as they are not really scheduled
        if run.is_backfill:
            continue

        # todo: run.dag is transient but needs to be set
        run.dag = dag
        # todo: preferably the integrity check happens at dag collection time
        run.verify_integrity(session=session)
        run.update_state(session=session)
        if run.state == State.RUNNING:
            make_transient(run)
            active_dag_runs.append(run)

    for run in active_dag_runs:
        self.log.debug("Examining active DAG run: %s", run)
        # this needs a fresh session sometimes tis get detached
        # Get a set of task instance related to this task for a specific date range.
        tis = run.get_task_instances(state=(State.NONE, State.UP_FOR_RETRY))

        # this loop is quite slow as it uses are_dependencies_met for
        # every task (in ti.is_runnable). This is also called in
        # update_state above which has already checked these tasks
        for ti in tis:
            task = dag.get_task(ti.task_id)

            # fixme: ti.task is transient but needs to be set
            ti.task = task

            # future: remove adhoc
            if task.adhoc:
                continue

            if ti.are_dependencies_met(
                    dep_context=DepContext(flag_upstream_failed=True),
                    session=session):
                self.log.debug('Queuing task: %s', ti)
                queue.append(ti.key)

```

## Overview

The Airflow scheduler spins up a process loop, which monitors and stays in sync with a folder for all DAG objects it may contain, and periodically (every minute or so) collects DAG parsing results and inspects active tasks to see whether they can be scheduled.

## Reference

- [Scheduling & Triggers — Airflow Documentation](https://airflow.apache.org/scheduler.html)

