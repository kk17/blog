CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

HUGO_VERSION=${HUGO_VERSION:-0.55.4}
hugo(){
    docker run -it --rm -v ${CURRENT_DIR}:/workspace -p 1313:1313 --workdir /workspace klakegg/hugo:${HUGO_VERSION} $@
}