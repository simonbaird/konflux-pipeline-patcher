# One-liners for specific use cases

If you run these in the git repo of your Konflux component, it will update the
pipelines and make a commit. If the commit looks good you can push a branch and
create a PR in the usual way.

Of course you don't have to run the script directly from curl. Feel
free to [install the pipeline-patcher script](README.md) and run the
`pipeline-patcher add-tasks` commands locally.

## SAST Unicode and Shell Check tasks

These two tasks will become required tasks for Red Hat Konflux builds after
March 31, 2025. See also [this
announcement](https://groups.google.com/a/redhat.com/g/konflux-announce/c/OEcuK1Sr7dI/m/xKwD_bMcAQAJ),
and [KONFLUX-2264](https://issues.redhat.com/browse/KONFLUX-2264).

```bash
curl -sL https://github.com/simonbaird/konflux-pipeline-patcher/raw/main/pipeline-patcher |
  bash -s add-tasks . sast-shell-check,sast-unicode-check &&
  git commit .tekton/*.yaml -m "Add shell and unicode sast pipeline tasks" \
    -m "https://issues.redhat.com/browse/KONFLUX-2264"
```

## SAST Coverity Check tasks

Beware there are some additional requirements and restrictions affecting this
task. See [this documentation (RH internal)](https://konflux.pages.redhat.com/docs/users/getting-started/components-applications.html#_sast_coverity_check_task)
for details.

```bash
curl -sL https://github.com/simonbaird/konflux-pipeline-patcher/raw/main/pipeline-patcher |
  bash -s add-tasks . sast-coverity-check,coverity-availability-check &&
  git commit .tekton/*.yaml -m "Add sast coverity pipeline task" \
    -m "https://issues.redhat.com/browse/KONFLUX-2264"
```

## Migration to add the build-image-index task

The SAST tasks mentioned above expect that your pipeline includes the
"build-image-index" task. If your component was on-boarded before that task was
added to the default pipeline definition, it's likely that you don't have it.

Adding the `build-image-index` task is a more complicated change that adding the
sast tasks, since it requires some task param values and some "runAfter"
configuration to be changed. The following command will attempt to add the
task and make the required changes to the Konflux pipelines in your
component's GitHub repo.

> [!NOTE]
> Currently this script reformats the yaml as a side-effect. When reviewing
> the change, it's useful to ignore whitespace, e.g. with `git show -b`.

> [!WARNING]
> Beware this is not well tested.

```bash
curl -sL https://github.com/simonbaird/konflux-pipeline-patcher/raw/add-build-image-index/pipeline-patcher |
  bash -s add-build-image-index . &&
  git commit .tekton/*.yaml -m "Add build-image-index pipeline task" \
    -m "https://github.com/simonbaird/konflux-pipeline-patcher" \
    -m "https://issues.redhat.com/browse/KONFLUX-2264" \
    -m "https://issues.redhat.com/browse/EC-1202"
```
