workspace(name = "bazel-example-sops-age")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

http_archive(
    name = "aspect_bazel_lib",
    sha256 = "e9505bd956da64b576c433e4e41da76540fd8b889bbd17617fe480a646b1bfb9",
    strip_prefix = "bazel-lib-1.35.0",
    url = "https://github.com/aspect-build/bazel-lib/releases/download/v1.35.0/bazel-lib-v1.35.0.tar.gz",
)

# Masmovil 2023-04-18 release
http_archive(
    name = "com_github_masmovil_bazel_rules",
    sha256 = "9c8ac4c60da1ccda076b2a8e5194a1d4bde96bcb44808ccb75ecca33b5669102",
    strip_prefix = "bazel-rules-0.5.0",
    urls = [
        "https://github.com/masmovil/bazel-rules/archive/refs/tags/v0.5.0.tar.gz",
    ],
)

# Loading phase -- I tend to put this here when I can to keep the stuff above somewhat ordered

load("@aspect_bazel_lib//lib:repositories.bzl", "aspect_bazel_lib_dependencies")

aspect_bazel_lib_dependencies()

load("@com_github_masmovil_bazel_rules//repositories:repositories.bzl", masmovil_repositories = "repositories")

masmovil_repositories()

http_archive(
    name = "age_darwin_amd64",
    build_file_content = "\n".join([
        """alias(name="age", actual="//:age/age", visibility = ["//visibility:public"])""",
        """alias(name="age-keygen", actual="//:age/age-keygen", visibility = ["//visibility:public"])""",
        "",  # readability during debug
    ]),
    sha256 = "81bdfa27906288b1b0d1952202a34c8020da9b01008761ca91100c87d416227c",
    urls = [
        "https://github.com/FiloSottile/age/releases/download/v1.1.1/age-v1.1.1-darwin-amd64.tar.gz",
    ],
)