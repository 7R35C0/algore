//:========================================================================
//: Licensed under the [MIT License](LICENSE).
//:
//: Tested with zig version 0.13.0 on Linux Fedora 39.
//:
//#
//# WARNING
//#   Be very careful with `rmv` step, the `setupRemove` does not check
//#   arguments, it just silently removes any user provided paths and can
//#   lead to unwanted results.
//#
//:
//: IMPORTANT
//: * Step `cov` assumes that [kcov](https://github.com/SimonKagstrom/kcov)
//:   is installed.
//: * Use a live http server to see the code coverage report and docs
//:   (zig-out/cov/index.html, zig-out/doc/index.html).
//: * Steps `run`, `fmt` and `rmv` can be used with arguments, like this
//:     `zig build <step> -- arg1 arg2 ...`
//:   where arguments are relative paths to the project folder.
//:     eg. `zig build rmv -- zig-out/cov zig-out/doc/index.html`
//: * Without arguments, step:
//:   * `run` does nothing, it must be used with file paths
//:   * `fmt` formats the files and folders defined in `setupFormat()`
//:   * `rmv` removes the zig-cache and zig-out folders
//:========================================================================

const std = @import("std");

// general configuration
const Config = struct {
    name: []const u8,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    root_source_file: std.Build.LazyPath,
    version: std.SemanticVersion,
};

pub fn build(b: *std.Build) void {
    // `name` is the name of project's root and entry file
    const name = "algore";

    // build configuration
    const cfg = Config{
        .name = name,
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{}),
        .root_source_file = b.path(
            b.fmt("src/{s}.zig", .{name}),
        ),
        .version = .{
            .major = 0,
            .minor = 1,
            .patch = 0,
        },
    };

    // expose library module for later use with `@import("cfg.name")`
    const mod = setupModule(b, cfg);

    // build static library
    // command: zig build lib
    // outputs: zig-out/lib
    const lib = setupStaticLibrary(b, cfg);

    // run tests
    // command: zig build tst
    // outputs: none
    const tst = setupTest(b, cfg);

    // generate code coverage
    // command: zig build cov
    // outputs: zig-out/cov
    setupCoverage(b, tst);

    // generate documentation
    // command: zig build doc
    // outputs: zig-out/doc
    setupDocumentation(b, lib);

    // run specific files
    // command: zig build run -- path1 path2 ...
    // outputs: zig-out/bin
    setupRun(b, cfg, mod);

    // format specific files and folders
    // command: zig build fmt -- path1 path2 ...
    // outputs: none
    setupFormat(b);

    // remove specific files and folders
    // command: zig build rmv -- path1 path2 ...
    // outputs: none
    setupRemove(b);
}

fn setupModule(b: *std.Build, cfg: Config) *std.Build.Module {
    const mod = b.addModule(
        cfg.name,
        .{
            .target = cfg.target,
            .optimize = cfg.optimize,
            .root_source_file = cfg.root_source_file,
        },
    );

    for (b.available_deps) |dep| {
        mod.addImport(dep[0], b.dependency(
            dep[0],
            .{
                .target = cfg.target,
                .optimize = cfg.optimize,
            },
        ).module(dep[0]));
    }

    return mod;
}

fn setupStaticLibrary(b: *std.Build, cfg: Config) *std.Build.Step.Compile {
    const lib_step = b.step(
        "lib",
        "Build static library",
    );

    const lib = b.addStaticLibrary(.{
        .name = cfg.name,
        .target = cfg.target,
        .optimize = cfg.optimize,
        .root_source_file = cfg.root_source_file,
        .version = cfg.version,
    });

    for (b.available_deps) |dep| {
        lib.root_module.addImport(dep[0], b.dependency(
            dep[0],
            .{
                .target = cfg.target,
                .optimize = cfg.optimize,
            },
        ).module(dep[0]));
    }

    const lib_install = b.addInstallArtifact(
        lib,
        .{},
    );
    lib_step.dependOn(&lib_install.step);

    return lib;
}

fn setupTest(b: *std.Build, cfg: Config) *std.Build.Step.Compile {
    const tst_step = b.step(
        "tst",
        "Run tests",
    );

    const tst = b.addTest(.{
        .name = cfg.name,
        .target = cfg.target,
        .optimize = cfg.optimize,
        .root_source_file = cfg.root_source_file,
        .version = cfg.version,
    });

    for (b.available_deps) |dep| {
        tst.root_module.addImport(dep[0], b.dependency(
            dep[0],
            .{
                .target = cfg.target,
                .optimize = cfg.optimize,
            },
        ).module(dep[0]));
    }

    const tst_run = b.addRunArtifact(tst);
    tst_step.dependOn(&tst_run.step);

    return tst;
}

fn setupCoverage(b: *std.Build, tst: *std.Build.Step.Compile) void {
    const cov_step = b.step(
        "cov",
        "Generate code coverage",
    );

    const cov_cache = b.pathJoin(&[_][]const u8{ b.cache_root.path.?, "cov" });

    const cov_run = b.addSystemCommand(&.{
        "kcov",
        "--clean",
        "--include-pattern=src/",
        "--output-interval=0",
        cov_cache,
    });
    cov_run.addArtifactArg(tst);

    const cov_install = b.addInstallDirectory(.{
        .install_dir = .{ .custom = "cov" },
        .install_subdir = "",
        .source_dir = .{
            .src_path = .{
                .owner = b,
                .sub_path = ".zig-cache/cov",
            },
        },
    });
    cov_install.step.dependOn(&cov_run.step);

    const cov_cache_remove = b.addRemoveDirTree(cov_cache);
    cov_cache_remove.step.dependOn(&cov_install.step);
    cov_step.dependOn(&cov_cache_remove.step);
}

fn setupDocumentation(b: *std.Build, lib: *std.Build.Step.Compile) void {
    const doc_step = b.step(
        "doc",
        "Generate documentation",
    );

    const doc_install = b.addInstallDirectory(.{
        .install_dir = .prefix,
        .install_subdir = "doc",
        .source_dir = lib.getEmittedDocs(),
    });
    doc_step.dependOn(&doc_install.step);
}

fn setupRun(b: *std.Build, cfg: Config, mod: *std.Build.Module) void {
    const run_step = b.step(
        "run",
        "Run specific files",
    );

    if (b.args) |paths| {
        for (paths) |path| {
            const exe = b.addExecutable(.{
                .name = std.fs.path.stem(path),
                .target = cfg.target,
                .optimize = cfg.optimize,
                .root_source_file = .{
                    .src_path = .{
                        .owner = b,
                        .sub_path = path,
                    },
                },
                .version = cfg.version,
            });
            exe.root_module.addImport(cfg.name, mod);

            const exe_install = b.addInstallArtifact(
                exe,
                .{},
            );
            const exe_run = b.addRunArtifact(exe);
            exe_run.step.dependOn(&exe_install.step);
            run_step.dependOn(&exe_run.step);
        }
    }
}

fn setupFormat(b: *std.Build) void {
    const fmt_step = b.step(
        "fmt",
        "Format specific files and folders",
    );

    var paths: []const []const u8 = &.{};

    if (b.args) |args| {
        paths = args;
    } else {
        paths = &.{
            "bench",
            "demo",
            "src",
            "utils",
            "build.zig",
            "build.zig.zon",
        };
    }

    const fmt = b.addFmt(.{
        .paths = paths,
        .check = false,
    });
    fmt_step.dependOn(&fmt.step);
}

fn setupRemove(b: *std.Build) void {
    const rmv_step = b.step(
        "rmv",
        "Remove specific files and folders",
    );

    if (b.args) |paths| {
        for (paths) |path| {
            rmv_step.dependOn(&b.addRemoveDirTree(path).step);
        }
    } else {
        rmv_step.dependOn(&b.addRemoveDirTree(b.cache_root.path.?).step);
        rmv_step.dependOn(&b.addRemoveDirTree(b.install_path).step);
    }
}
