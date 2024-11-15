const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libjpeg_dep = b.dependency("libjpeg", .{});

    const jconfig_h = b.addConfigHeader(.{
        .style = .{ .cmake = libjpeg_dep.path("jconfig.h.in") },
        .include_path = "jconfig.h",
    }, .{
        .JPEG_LIB_VERSION = 80,
        .VERSION = "3.0.3",
        .LIBJPEG_TURBO_VERSION_NUMBER = 3000003,
        .C_ARITH_CODING_SUPPORTED = 1,
        .D_ARITH_CODING_SUPPORTED = 1,
        .WITH_SIMD = null,
        .RIGHT_SHIFT_IS_UNSIGNED = null,
    });

    const jconfigint_h = b.addConfigHeader(.{
        .style = .{ .cmake = libjpeg_dep.path("jconfigint.h.in") },
        .include_path = "jconfigint.h",
    }, .{
        .BUILD = "20241115",
        .HIDDEN = "__attribute__((visibility(\"hidden\")))",
        .INLINE = "__inline__ __attribute__((always_inline))",
        .THREAD_LOCAL = "__thread",
        .CMAKE_PROJECT_NAME = "libjpeg-turbo",
        .VERSION = "3.0.3",
        .SIZE_T = @sizeOf(usize),
        .HAVE_BUILTIN_CTZL = 1,
        .HAVE_INTRIN_H = null,
        .C_ARITH_CODING_SUPPORTED = 1,
        .D_ARITH_CODING_SUPPORTED = 1,
        .WITH_SIMD = null,
    });

    const lib = b.addStaticLibrary(.{
        .name = "jpeg",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    lib.addConfigHeader(jconfig_h);
    lib.addConfigHeader(jconfigint_h);
    lib.addCSourceFiles(.{
        .root = libjpeg_dep.path("."),
        .files = &jpeg16_sources,
        .flags = &.{},
    });
    lib.addCSourceFiles(.{
        .root = libjpeg_dep.path("."),
        .files = &jpeg12_sources,
        .flags = &.{},
    });
    lib.addCSourceFiles(.{
        .root = libjpeg_dep.path("."),
        .files = &jpeg_sources,
        .flags = &.{},
    });
    lib.addCSourceFiles(.{
        .root = libjpeg_dep.path("."),
        .files = &arith_enc_dec,
        .flags = &.{},
    });
    lib.addIncludePath(b.path("src"));
    lib.addIncludePath(libjpeg_dep.path("."));
    b.installArtifact(lib);

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}

const jpeg16_sources = [_][]const u8{
    "jcapistd.c",
    "jccolor.c",
    "jcdiffct.c",
    "jclossls.c",
    "jcmainct.c",
    "jcprepct.c",
    "jcsample.c",
    "jdapistd.c",
    "jdcolor.c",
    "jddiffct.c",
    "jdlossls.c",
    "jdmainct.c",
    "jdpostct.c",
    "jdsample.c",
    "jutils.c",
};
const jpeg12_sources = [_][]const u8{
    "jccoefct.c",
    "jcdctmgr.c",
    "jdcoefct.c",
    "jddctmgr.c",
    "jdmerge.c",
    "jfdctfst.c",
    "jfdctint.c",
    "jidctflt.c",
    "jidctfst.c",
    "jidctint.c",
    "jidctred.c",
    "jquant1.c",
    "jquant2.c",
};

const jpeg_sources = [_][]const u8{
    "jcapimin.c",
    "jchuff.c",
    "jcicc.c",
    "jcinit.c",
    "jclhuff.c",
    "jcmarker.c",
    "jcmaster.c",
    "jcomapi.c",
    "jcparam.c",
    "jcphuff.c",
    "jctrans.c",
    "jdapimin.c",
    "jdatadst.c",
    "jdatasrc.c",
    "jdhuff.c",
    "jdicc.c",
    "jdinput.c",
    "jdlhuff.c",
    "jdmarker.c",
    "jdmaster.c",
    "jdphuff.c",
    "jdtrans.c",
    "jerror.c",
    "jfdctflt.c",
    "jmemmgr.c",
    "jmemnobs.c",
    "jpeg_nbits.c",
};

const arith_enc_dec = [_][]const u8{
    "jaricom.c",
    "jcarith.c",
    "jdarith.c",
};
