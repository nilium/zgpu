const std = @import("std");
const log = std.log.scoped(.zgpu);

pub const WebgpuBackend = enum {
    wgpu,
};

const default_options = struct {
    const uniforms_buffer_size = 4 * 1024 * 1024;
    const webgpu_backend = WebgpuBackend.wgpu;
    const buffer_pool_size = 256;
    const texture_pool_size = 256;
    const texture_view_pool_size = 256;
    const sampler_pool_size = 16;
    const render_pipeline_pool_size = 128;
    const compute_pipeline_pool_size = 128;
    const bind_group_pool_size = 32;
    const bind_group_layout_pool_size = 32;
    const pipeline_layout_pool_size = 32;
    const max_num_bindings_per_group = 10;
    const max_num_bind_groups_per_pipeline = 4;
};

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const options = .{
        .webgpu_backend = b.option(
            WebgpuBackend,
            "webgpu_backend",
            "Set WebGPU backend",
        ) orelse default_options.webgpu_backend,
        .uniforms_buffer_size = b.option(
            u64,
            "uniforms_buffer_size",
            "Set uniforms buffer size",
        ) orelse default_options.uniforms_buffer_size,
        .buffer_pool_size = b.option(
            u32,
            "buffer_pool_size",
            "Set buffer pool size",
        ) orelse default_options.buffer_pool_size,
        .texture_pool_size = b.option(
            u32,
            "texture_pool_size",
            "Set texture pool size",
        ) orelse default_options.texture_pool_size,
        .texture_view_pool_size = b.option(
            u32,
            "texture_view_pool_size",
            "Set texture view pool size",
        ) orelse default_options.texture_view_pool_size,
        .sampler_pool_size = b.option(
            u32,
            "sampler_pool_size",
            "Set sample pool size",
        ) orelse default_options.sampler_pool_size,
        .render_pipeline_pool_size = b.option(
            u32,
            "render_pipeline_pool_size",
            "Set render pipeline pool size",
        ) orelse default_options.render_pipeline_pool_size,
        .compute_pipeline_pool_size = b.option(
            u32,
            "compute_pipeline_pool_size",
            "Set compute pipeline pool size",
        ) orelse default_options.compute_pipeline_pool_size,
        .bind_group_pool_size = b.option(
            u32,
            "bind_group_pool_size",
            "Set bind group pool size",
        ) orelse default_options.bind_group_pool_size,
        .bind_group_layout_pool_size = b.option(
            u32,
            "bind_group_layout_pool_size",
            "Set bind group layout pool size",
        ) orelse default_options.bind_group_layout_pool_size,
        .pipeline_layout_pool_size = b.option(
            u32,
            "pipeline_layout_pool_size",
            "Set pipeline layout pool size",
        ) orelse default_options.pipeline_layout_pool_size,
        .max_num_bindings_per_group = b.option(
            u32,
            "max_num_bindings_per_group",
            "Set maximum number of bindings per bind group",
        ) orelse default_options.max_num_bindings_per_group,
        .max_num_bind_groups_per_pipeline = b.option(
            u32,
            "max_num_bind_groups_per_pipeline",
            "Set maximum number of bindings groups per pipeline",
        ) orelse default_options.max_num_bind_groups_per_pipeline,
    };

    const options_step = b.addOptions();
    inline for (std.meta.fields(@TypeOf(options))) |field| {
        options_step.addOption(field.type, field.name, @field(options, field.name));
    }

    const options_module = options_step.createModule();

    const wgpu_common_mod = b.addModule("wgpu_common", .{
        .root_source_file = b.path("src/wgpu_common.zig"),
        .imports = &.{
            .{ .name = "zgpu_options", .module = options_module },
        },
        .target = target,
        .optimize = optimize,
    });

    const root_mod = b.addModule("root", .{
        .root_source_file = switch (options.webgpu_backend) {
            .wgpu => b.path("src/wgpu_native/zgpu.zig"),
        },
        .imports = &.{
            .{ .name = "zgpu_options", .module = options_module },
            .{ .name = "zpool", .module = b.dependency("zpool", .{}).module("root") },
            .{ .name = "wgpu_common", .module = wgpu_common_mod },
        },
        .target = target,
        .optimize = optimize,
    });
    root_mod.addIncludePath(b.path("src"));

    const webgpu_lib = switch (options.webgpu_backend) {
        .wgpu => wgpu: {
            // TODO: add ABI checks for all the Android variants.
            const arch = switch (target.result.cpu.arch) {
                .aarch64 => "aarch64",
                .x86 => "i686",
                .x86_64 => "x86_64",
                else => std.debug.panic("unsupported zgpu architecture: {any}", .{@tagName(target.result.cpu.arch)}),
            };
            const os = switch (target.result.os.tag) {
                .macos => "macos",
                .ios => "ios",
                .windows => "windows",
                else => std.debug.panic("unsupported zgpu operating system: {any}", .{@tagName(target.result.os.tag)}),
            };
            var libc: [:0]const u8 = "";
            if (target.result.os.tag == .windows) {
                libc = "_gnu";
            }

            const wgpu_dep_name = std.mem.concat(b.allocator, u8, &[_][]const u8{
                "wgpu_",
                os,
                "_",
                arch,
                libc,
                "_release",
            }) catch std.debug.panic("unable to allocate for wgpu-native dependency name", .{});

            const wgpu_dep = b.lazyDependency(wgpu_dep_name, .{}) orelse
                std.debug.panic("could not load wgpu-native dependency {s}", .{wgpu_dep_name});

            const cwgpu = b.addTranslateC(.{
                .root_source_file = wgpu_dep.path("include/webgpu/wgpu.h"),
                .optimize = optimize,
                .target = target,
            });
            cwgpu.addIncludePath(wgpu_dep.path("include/webgpu"));
            const cwgpu_mod = cwgpu.createModule();

            const zwgpu = b.addLibrary(.{
                .name = "zwgpu",
                .root_module = b.createModule(.{
                    .target = target,
                    .optimize = optimize,
                    .link_libc = true,
                    .link_libcpp = target.result.abi != .msvc,
                }),
            });
            b.installArtifact(zwgpu);

            linkSystemDeps(b, zwgpu);
            zwgpu.root_module.addObjectFile(wgpu_dep.path("lib/libwgpu_native.a"));
            zwgpu.root_module.addImport("cwgpu", cwgpu_mod);

            root_mod.addObjectFile(wgpu_dep.path("lib/libwgpu_native.a"));
            root_mod.addImport("cwgpu", cwgpu_mod);

            break :wgpu zwgpu;
        },
    };
    const test_step = b.step("test", "Run zgpu tests");

    const tests = b.addTest(.{
        .name = "zgpu-tests",
        .root_module = root_mod,
    });
    tests.root_module.addIncludePath(b.path("src"));
    tests.root_module.linkLibrary(webgpu_lib);
    linkSystemDeps(b, tests);
    b.installArtifact(tests);

    test_step.dependOn(&b.addRunArtifact(tests).step);
}

pub fn linkSystemDeps(b: *std.Build, compile_step: *std.Build.Step.Compile) void {
    var mod = compile_step.root_module;
    switch (compile_step.rootModuleTarget().os.tag) {
        .windows => {
            if (b.lazyDependency("system_sdk", .{})) |system_sdk| {
                compile_step.root_module.addLibraryPath(system_sdk.path("windows/lib/x86_64-windows-gnu"));
            }
            compile_step.root_module.linkSystemLibrary("ole32", .{});
            compile_step.root_module.linkSystemLibrary("dxguid", .{});
        },
        .macos => {
            mod.linkSystemLibrary("objc", .{});
            mod.linkFramework("Metal", .{});
            mod.linkFramework("CoreGraphics", .{});
            mod.linkFramework("Foundation", .{});
            mod.linkFramework("IOKit", .{});
            mod.linkFramework("IOSurface", .{});
            mod.linkFramework("QuartzCore", .{});
        },
        else => {},
    }
}

pub fn checkTargetSupported(target: std.Target) bool {
    const supported = switch (target.os.tag) {
        .windows => target.cpu.arch.isX86() and target.abi.isGnu(),
        .linux => (target.cpu.arch.isX86() or target.cpu.arch.isAARCH64()) and target.abi.isGnu(),
        .macos => blk: {
            if (!target.cpu.arch.isAARCH64()) break :blk false;

            // If min. target macOS version is lesser than the min version we have available, then
            // our Dawn binary is incompatible with the target.
            if (target.os.version_range.semver.min.order(
                .{ .major = 12, .minor = 0, .patch = 0 },
            ) == .lt) break :blk false;
            break :blk true;
        },
        else => false,
    };
    if (supported == false) {
        log.warn("\n" ++
            \\---------------------------------------------------------------------------
            \\
            \\Dawn/WebGPU binary for this target is not available.
            \\
            \\Following targets are supported:
            \\
            \\x86_64-windows-gnu
            \\x86_64-linux-gnu
            \\x86_64-macos.12.0.0-none
            \\aarch64-linux-gnu
            \\aarch64-macos.12.0.0-none
            \\
            \\---------------------------------------------------------------------------
            \\
        , .{});
    }
    return supported;
}
