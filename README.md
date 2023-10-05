# bazel-example-sops-gpg
In order to isolate this complexity I'm having with GPG-based SOPS decrypt, I'm separating off to another project.  No problem with decrypt using AWS roles and secrets access, just with the GPG config

## Convenience Aliases

The following commands use a `select()` against aggregates such as //settings:osx_amd64 to choose appropriate binaries:

 - bazel run //age:age -- --help
 - bazel run //age:age-keygen -- --help


## Create a Private Key

With aliases, we automatically choose a platform-compatible binary:
```
mkdir secrets
bazel run age:age-keygen -- --output secrets/age-key.txt
```

(of course, bazel will only pull/unpack the correct binary for your hardware)

This is demonstrated in `//age:genkey`:
```
$ bazel build //age:genkey
INFO: Analyzed target //age:genkey (1 packages loaded, 7 targets configured).
INFO: ...
Public key: age1h3pnqau4e5rz2myeaq789akzsachtnau7cwqhrwapc28h5s8ye2ssw2j90
Target //age:genkey up-to-date:
  bazel-bin/age/key.txt
INFO: ...
```
(as this is a demo, of course this is not my personal key, and you'll see different results each time)

## Encrypy a Thing with PKCS


