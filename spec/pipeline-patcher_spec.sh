# shellcheck shell=bash

Describe 'command smoke test'
  It 'shows help'
    When run ./pipeline-patcher help
    The status should be success
    The stdout should include "Konflux Pipeline Patcher"
    The stdout should include "Usage:"
  End

  It 'lists tasks'
    # Beware this pulls data from github
    When run ./pipeline-patcher list-tasks
    The status should be success
    The stdout line 1 should eq "apply-tags 0.1"
    The stdout should include "git-clone "
    The stdout should include "clair-scan "
  End

  It 'shows task yaml'
    # Beware this pulls data from github
    When run ./pipeline-patcher task-yaml git-clone
    The status should be success
    # Just a sanity check
    The stdout line 1 should eq "- name: clone-repository"
    The stdout should include "        value: quay.io/konflux-ci/tekton-catalog/task-git-clone:"
    The stdout should include "    resolver: bundles"
  End
End

Describe 'misc helpers'
  Include ./pipeline-patcher

  It 'indents'
    indent_test() {
      printf "some\ntext" | indented
    }
    When call indent_test
    The status should be success
    The output should equal "$(printf "  some\n  text")"
  End
End

Describe 'task-refs'
  Include ./pipeline-patcher

  Parameters
    "foo:0.1"
    "quay.io/konflux-ci/tekton-catalog/task-foo:0.1"
    "quay.io/konflux-ci/tekton-catalog/task-foo:0.1@sha256:whatever"
    "foo" "0.1"
  End

  It 'produces task refs'
    trusted_task_data() {
      cat ./spec/data/fake_trusted_tasks.yaml
    }
    When call get_pinned_task_bundle_ref "$1" ${2:-""}
    The status should be success
    The stdout should equal "quay.io/konflux-ci/tekton-catalog/task-foo:0.1@sha256:somesha"
  End
End

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
 .tekton/cli-v06-pull-request.yaml | 52 +++++++++++++++++++++++++++++++++++++++
 .tekton/cli-v06-push.yaml         | 52 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 104 insertions(+)"
    The value "$(show_diff)" should include "+    - name: sast-shell-check"
    The value "$(show_diff)" should include "+            value: quay.io/konflux-ci/tekton-catalog/task-sast-shell-check-oci-ta:0.1@sha256"
    The value "$(show_diff)" should include "+    - name: sast-unicode-check"
    The value "$(show_diff)" should include "+            value: quay.io/konflux-ci/tekton-catalog/task-sast-unicode-check-oci-ta:0.1@sha256"
    # Todo maybe: Make a baseline file and check that it matches exactly
  End
End

Describe 'add-tasks-with-build-container'
  # Prepare a git repo for testing
  # Todo: Move this into a helper..?
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
 .tekton/mintmaker-renovate-image-pull-request.yaml | 48 ++++++++++++++++++++++
 .tekton/mintmaker-renovate-image-push.yaml         | 48 ++++++++++++++++++++++
 2 files changed, 96 insertions(+)"
    The value "$(show_diff)" should include "+    - name: sast-shell-check"
    The value "$(show_diff)" should include "+            value: quay.io/konflux-ci/tekton-catalog/task-sast-shell-check:0.1@sha256"
    The value "$(show_diff)" should include "+    - name: sast-unicode-check"
    The value "$(show_diff)" should include "+            value: quay.io/konflux-ci/tekton-catalog/task-sast-unicode-check:0.1@sha256"

    # Check that build-image-index was replaced with build-container
    The value "$(show_diff)" should not include 'build-image-index'
    The value "$(show_diff)" should include '+          value: $(tasks.build-container.results.IMAGE_URL)'
    The value "$(show_diff)" should include '+          value: $(tasks.build-container.results.IMAGE_DIGEST)'
    The value "$(show_diff)" should include '+        - build-container'

    # Todo maybe: Make a baseline file and check that it matches exactly
  End
End
