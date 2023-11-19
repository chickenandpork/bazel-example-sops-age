workspace(name = "bazel-example-sops-age")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

http_archive(
    name = "aspect_bazel_lib",
    sha256 = "4b32cf6feab38b887941db022020eea5a49b848e11e3d6d4d18433594951717a",
    strip_prefix = "bazel-lib-2.0.1",
    url = "https://github.com/aspect-build/bazel-lib/releases/download/v2.0.1/bazel-lib-v2.0.1.tar.gz",
)

## Masmovil 2023-04-18 release
#http_archive(
#    name = "com_github_masmovil_bazel_rules",
#    sha256 = "9c8ac4c60da1ccda076b2a8e5194a1d4bde96bcb44808ccb75ecca33b5669102",
#    strip_prefix = "bazel-rules-0.5.0",
#    urls = [
#        "https://github.com/masmovil/bazel-rules/archive/refs/tags/v0.5.0.tar.gz",
#    ],
#)
#
#local_repository(
#    name = "com_github_masmovil_bazel_rules",
#    path = "/Users/allanc/src/rules_helm",
#)
git_repository(
    name = "com_github_masmovil_bazel_rules",
    branch = "feature/enable-sops-with-age",
    remote = "https://github.com/chickenandpork/rules_helm.git",
)

# Loading phase -- I tend to put this here when I can to keep the stuff above somewhat ordered

load("@aspect_bazel_lib//lib:repositories.bzl", "aspect_bazel_lib_dependencies")

aspect_bazel_lib_dependencies()

load("@com_github_masmovil_bazel_rules//repositories:repositories.bzl", masmovil_repositories = "repositories")

masmovil_repositories()
