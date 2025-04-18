# shellcheck shell=bash

#
# Make a git repo with some real pipelines in it, add tasks to those pipelines,
# check that it succeeds, and that diff looks correct
#
Describe 'add-tasks'
  # Prepare a git repo for testing
  # Todo: Move this into a helper..?
  tmp_dir=$(mktemp -d)
  trap "rm -rf $tmp_dir" EXIT
  (
    example_from_github="https://raw.githubusercontent.com/enterprise-contract/ec-cli/a679ce9f52acc7223504867c8871ddd76c9f1ea7"
    cd $tmp_dir && git init . && mkdir .tekton && cd .tekton
    for y in push pull-request; do curl -sLO $example_from_github/.tekton/cli-v06-$y.yaml; done
    git add * && git commit -m "Testing"
  ) > /dev/null

  show_diff() {
    cd $tmp_dir && git diff
  }

  It 'produces expected output'
    # Beware this pulls data from both github and quay
    When run ./pipeline-patcher add-tasks $tmp_dir sast-shell-check,sast-unicode-check
    The status should be success
    The output should equal "Adding task sast-shell-check-oci-ta to pipeline $tmp_dir/.tekton/cli-v06-pull-request.yaml
Adding task sast-unicode-check-oci-ta to pipeline $tmp_dir/.tekton/cli-v06-pull-request.yaml
Adding task sast-shell-check-oci-ta to pipeline $tmp_dir/.tekton/cli-v06-push.yaml
Adding task sast-unicode-check-oci-ta to pipeline $tmp_dir/.tekton/cli-v06-push.yaml
 .tekton/cli-v06-pull-request.yaml | 54 +++++++++++++++++++++++++++++++++++++++
 .tekton/cli-v06-push.yaml         | 54 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 108 insertions(+)"
    The value "$(show_diff)" should include "+    - name: sast-shell-check"
    The value "$(show_diff)" should include "+            value: quay.io/konflux-ci/tekton-catalog/task-sast-shell-check-oci-ta:0.1@sha256"
    The value "$(show_diff)" should include "+    - name: sast-unicode-check"
    The value "$(show_diff)" should include "+            value: quay.io/konflux-ci/tekton-catalog/task-sast-unicode-check-oci-ta:0.2@sha256"
    # Todo maybe: Make a baseline file and check that it matches exactly
  End
End

#
# The same as the above except that the pipelines are older and do not have the
# build-image-index task
#
Describe 'add-tasks with build-container instead of build-image-index'
  tmp_dir=$(mktemp -d)
  trap "rm -rf $tmp_dir" EXIT
  (
    example_from_github="https://raw.githubusercontent.com/konflux-ci/mintmaker-renovate-image/9ca00ff4e7d87cfb768a2b6eff0185e9b8c8745f"
    cd $tmp_dir && git init . && mkdir .tekton && cd .tekton
    for y in push pull-request; do curl -sLO $example_from_github/.tekton/mintmaker-renovate-image-$y.yaml; done
    git add * && git commit -m "Testing"
  ) > /dev/null

  show_diff() {
    cd $tmp_dir && git diff
  }

  It 'produces expected output'
    # Beware this pulls data from both github and quay
    When run ./pipeline-patcher add-tasks $tmp_dir sast-shell-check,sast-unicode-check
    The status should be success
    The output should equal "Adding task sast-shell-check to pipeline $tmp_dir/.tekton/mintmaker-renovate-image-pull-request.yaml
Adding task sast-unicode-check to pipeline $tmp_dir/.tekton/mintmaker-renovate-image-pull-request.yaml
Adding task sast-shell-check to pipeline $tmp_dir/.tekton/mintmaker-renovate-image-push.yaml
Adding task sast-unicode-check to pipeline $tmp_dir/.tekton/mintmaker-renovate-image-push.yaml
 .tekton/mintmaker-renovate-image-pull-request.yaml | 50 ++++++++++++++++++++++
 .tekton/mintmaker-renovate-image-push.yaml         | 50 ++++++++++++++++++++++
 2 files changed, 100 insertions(+)"
    The value "$(show_diff)" should include "+    - name: sast-shell-check"
    The value "$(show_diff)" should include "+            value: quay.io/konflux-ci/tekton-catalog/task-sast-shell-check:0.1@sha256"
    The value "$(show_diff)" should include "+    - name: sast-unicode-check"
    The value "$(show_diff)" should include "+            value: quay.io/konflux-ci/tekton-catalog/task-sast-unicode-check:0.2@sha256"

    # Check that build-image-index was replaced with build-container
    The value "$(show_diff)" should not include 'build-image-index'
    The value "$(show_diff)" should include '+          value: $(tasks.build-container.results.IMAGE_URL)'
    The value "$(show_diff)" should include '+          value: $(tasks.build-container.results.IMAGE_DIGEST)'
    The value "$(show_diff)" should include '+        - build-container'

    # Todo maybe: Make a baseline file and check that it matches exactly
  End
End

#
# Use the experimental add-build-image-index command to upgrade the
# pipeline to include the build-image-index task and make some related
# changes so it works correctly.
#
Describe 'migrates the pipeline to include build-image-index'
  tmp_dir=$(mktemp -d)
  trap "rm -rf $tmp_dir" EXIT
  (
    example_from_github="https://raw.githubusercontent.com/konflux-ci/mintmaker-renovate-image/9ca00ff4e7d87cfb768a2b6eff0185e9b8c8745f"
    cd $tmp_dir && git init . && mkdir .tekton && cd .tekton
    for y in push pull-request; do curl -sLO $example_from_github/.tekton/mintmaker-renovate-image-$y.yaml; done
    git add * && git commit -m "Testing"
  ) > /dev/null

  show_diff() {
    cd $tmp_dir && git diff -b
  }

  It 'migrates pipeline'
    # Beware this pulls data from both github and quay
    When run ./pipeline-patcher add-build-image-index $tmp_dir
    The status should be success

    The output should equal "Adding task build-image-index to pipeline $tmp_dir/.tekton/mintmaker-renovate-image-pull-request.yaml
Adding task build-image-index to pipeline $tmp_dir/.tekton/mintmaker-renovate-image-push.yaml"

    The value "$(show_diff)" should include "+      - name: build-image-index"

    The value "$(show_diff)" should include "+              value: quay.io/konflux-ci/tekton-catalog/task-build-image-index:"

    The value "$(show_diff)" should include "-        value: \$(tasks.build-container.results.IMAGE_URL)
+            value: \$(tasks.build-image-index.results.IMAGE_URL)"

    The value "$(show_diff)" should include "runAfter:
-        - build-container
+          - build-image-index"

  End
End
