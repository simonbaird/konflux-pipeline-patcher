
# A command line tool to help patch your Konflux pipelines

## Installation

```bash
curl -sLO https://github.com/simonbaird/konflux-pipeline-patcher/raw/main/pipeline-patcher && chmod a+x ./pipeline-patcher
```

## Usage

```bash
# Show a list of known pipeline tasks
./pipeline-patcher list-tasks

# Show the latest trusted bundle ref for given pipeline task
./pipeline-patcher task-ref <task-name> <version>

# Output a snippet of yaml suitable for adding a task to a Konflux pipeline
./pipeline-patcher task-yaml <task-name>

# Modify a Konflux pipeline definition to add a new task
./pipeline-patcher patch <path-to-pipeline-yaml> <new-task-name>

# Modify all the Konflux pipelines in a git repo to add a new task
./pipeline-patcher patch-all <path-to-git-repo> <new-task-name>

# Show this help
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
