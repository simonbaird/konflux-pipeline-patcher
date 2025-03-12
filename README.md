
# A command line tool to help patch your Konflux pipelines

## Installation

```bash
curl -sLO https://github.com/simonbaird/konflux-pipeline-patcher/raw/main/pipeline-patcher && chmod a+x ./pipeline-patcher
```

## Usage

Use the built in help to see the commands available.

```bash
./pipeline-patcher help
```

## Requirements

* bash
* yq
* jq
* oras
* awk

## Status

It's functional, but should be considered a POC/demo at this stage.

## See also

* <https://github.com/konflux-ci/build-definitions/>
* <https://gitlab.cee.redhat.com/ynanavat/generate-bulk-tekton-prs/>
