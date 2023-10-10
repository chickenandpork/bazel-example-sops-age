def attrfilepath(ctx, f):
    """Return the sop file relative path of f."""
    return f.path

def declare_output(ctx, f, outputs):
    """In declaring output files, we simpultaneously add to the list of outputs and return the path
    of the file.
    """

    prefix = ctx.attr.crypttext_prefix
    out = ctx.actions.declare_file(prefix + f.basename)
    outputs.append(out)
    return out.path

def _sops_decrypt_file_impl(ctx):
    """This implementation services the decryption of a single file using SOPS and "age"
    Args:  (via ctx)
        name: A unique name for this rule.
        srcs: Array of plaintext files to decrypt
        debug: I left some debug statements in, default hidden
        plaintext_prefix: prefix to prepend plaintext results of decrypting src
        age_recipient_file: text file providing public key of receipient
    """

    inputs = [ctx.file.age_recipient_file] + ctx.files.srcs  # []+ to copy to avoid being a frozen/immutable list
    outputs = []

    # Format of a recipient file (generated by age-keygen):
    # # created: 2023-10-06T21:55:10-07:00
    # # public key: age1xxxxxxx
    # AGE-SECRET-KEY-12345678...
    ###if ctx.attr.debug:
    ###    print("{} recipient files".format(len(ctx.file.age_recipient_file)))

    sops = ctx.toolchains["@com_github_masmovil_bazel_rules//toolchains/sops:toolchain_type"].sopsinfo.tool.files.to_list()[0]

    gpg = ctx.toolchains["@com_github_masmovil_bazel_rules//toolchains/gpg:toolchain_type"].gpginfo.tool.files.to_list()[0]

    inputs += [gpg, sops]

    exec_file = ctx.actions.declare_file(ctx.label.name + "_sops_bash")

    # Generates the exec bash file with the provided substitutions
    ctx.actions.expand_template(
        template = ctx.file._script_template,
        output = exec_file,
        is_executable = True,
        substitutions = {
            "{DECRYPT_FILES}": "\n".join([
                "\tdecrypt_file %s %s" % (attrfilepath(ctx, f), declare_output(ctx, f, outputs))
                for f in ctx.files.srcs
            ]),
            "{RECIPIENT_FILE}": ctx.file.age_recipient_file.path,
            "{SOPS_BINARY_PATH}": sops.path,
            "{GPG_BINARY}": gpg.path,
            "{DEBUG}": str(ctx.attr.debug).lower(),
        },
    )

    ctx.actions.run(
        inputs = inputs,
        outputs = outputs,
        arguments = [],
        executable = exec_file,
        execution_requirements = {
            "local": "1",
        },
        use_default_shell_env = True,
    )

    return [
        DefaultInfo(
            files = depset(outputs),
            runfiles = ctx.runfiles(files = inputs),
        ),
    ]

sops_decrypt_file = rule(
    implementation = _sops_decrypt_file_impl,
    attrs = {
        "age_recipient_file": attr.label(allow_single_file = True, mandatory = True),
        "debug": attr.bool(mandatory = False, default = False),
        "crypttext_prefix": attr.string(mandatory = False, default = "dec."),
        "srcs": attr.label_list(allow_files = True, mandatory = True),
        "_script_template": attr.label(allow_single_file = True, default = ":sops-age-decrypt.sh.tpl"),
        "_age_binary": attr.label(allow_single_file = True, default = "//age:age"),  # should be a toolchain
    },
    toolchains = [
        "@com_github_masmovil_bazel_rules//toolchains/sops:toolchain_type",
        "@com_github_masmovil_bazel_rules//toolchains/gpg:toolchain_type",
    ],
    doc = """Encrypts a secret; secrets should not be committed to version-control in plaintext,
    which is a justification for the SOPS technology.  This is intended to be used for E2E testing,
    hence the decrypted content should use a generated secert that is specific to the build but not
    committed to version-control.

    A "formatted like age-genkey'd file" recipient is a file that looks like the following.  Note
    that the AGE-* key isn't used, just the "public key:" part, so you can fake it just as easily:
    ```
    # created: 2023-10-06T21:55:10-07:00
    # public key: age1xxxxxxx
    AGE-SECRET-KEY-12345678...
    ```

    Args:
        name: a unique name for the instance of this rule
        srcs: list of plaintext data files to decrypt
        age_recipient_files: public keys of receipients formatted like age-genkey'd files
        crypttext_prefix: a prefix on files after decryption (default "dec.")

    """,
)
