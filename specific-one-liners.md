# One-liners for specific use cases

If you run these in the git repo of your Konflux component, it will update the
pipelines and make a commit. If the commit looks good you can push a branch and
create a PR in the usual way.

Of course you don't have to run the script directly from curl. Feel
free to [install the pipeline-patcher script](README.md) and run the
`pipeline-patcher patch-all` commands locally.

## SAST Unicode and Shell Check tasks

These two tasks will become required tasks for Red Hat Konflux builds after
March 31, 2025. See also [this
announcement](https://groups.google.com/a/redhat.com/g/konflux-announce/c/OEcuK1Sr7dI/m/xKwD_bMcAQAJ),
and [KONFLUX-2264](https://issues.redhat.com/browse/KONFLUX-2264).

### For pipelines using the trusted artifacts/oci-ta tasks

```bash
curl -sL https://github.com/simonbaird/konflux-pipeline-patcher/raw/main/pipeline-patcher |
  bash -s patch-all . sast-shell-check-oci-ta,sast-unicode-check-oci-ta &&
  git commit .tekton/*.yaml -m "Add shell and unicode sast pipeline tasks" \
    -m "https://issues.redhat.com/browse/KONFLUX-2264"
```

### For pipelines not using trusted artifacts

```bash
curl -sL https://github.com/simonbaird/konflux-pipeline-patcher/raw/main/pipeline-patcher |
  bash -s patch-all . sast-shell-check,sast-unicode-check &&
  git commit .tekton/*.yaml -m "Add shell and unicode sast pipeline tasks" \
    -m "https://issues.redhat.com/browse/KONFLUX-2264"
```

## SAST Coverity Check tasks

Beware there are some additional requirements and restrictions affecting this
task. See [this documentation (RH internal)](https://konflux.pages.redhat.com/docs/users/getting-started/components-applications.html#_sast_coverity_check_task)
for details.

Note that you can ignore the "Consider if there's an oci-ta version..." message
produced when adding the "coverity-availability-check" task to an oci-ta
pipeline.

### For pipelines using the trusted artifacts/oci-ta tasks

```bash
curl -sL https://github.com/simonbaird/konflux-pipeline-patcher/raw/main/pipeline-patcher |
  bash -s patch-all . sast-coverity-check-oci-ta,coverity-availability-check &&
  git commit .tekton/*.yaml -m "Add sast coverity pipeline task" \
    -m "https://issues.redhat.com/browse/KONFLUX-2264"
```

### For pipelines not using trusted artifacts

```bash
curl -sL https://github.com/simonbaird/konflux-pipeline-patcher/raw/main/pipeline-patcher |
  bash -s patch-all . sast-coverity-check,coverity-availability-check &&
  git commit .tekton/*.yaml -m "Add sast coverity pipeline task" \
    -m "https://issues.redhat.com/browse/KONFLUX-2264"
```
