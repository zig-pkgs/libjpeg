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

    const jpeg16 = b.addStaticLibrary(.{
        .name = "jpeg16",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    jpeg16.addConfigHeader(jconfig_h);
    jpeg16.addConfigHeader(jconfigint_h);
    jpeg16.addCSourceFiles(.{
        .root = libjpeg_dep.path("."),
        .files = &jpeg16_sources,
        .flags = &.{},
    });
    jpeg16.defineCMacro("BITS_IN_JSAMPLE", "16");
    jpeg16.addIncludePath(b.path("src"));
    jpeg16.addIncludePath(libjpeg_dep.path("."));
    b.installArtifact(jpeg16);

    const jpeg12 = b.addStaticLibrary(.{
        .name = "jpeg12",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    jpeg12.addConfigHeader(jconfig_h);
    jpeg12.addConfigHeader(jconfigint_h);
    jpeg12.addCSourceFiles(.{
        .root = libjpeg_dep.path("."),
        .files = &jpeg12_sources,
        .flags = &.{},
    });
    jpeg12.defineCMacro("BITS_IN_JSAMPLE", "12");
    jpeg12.addIncludePath(b.path("src"));
    jpeg12.addIncludePath(libjpeg_dep.path("."));
    b.installArtifact(jpeg12);

    const jpeg = b.addStaticLibrary(.{
        .name = "jpeg",
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    jpeg.addConfigHeader(jconfig_h);
    jpeg.addConfigHeader(jconfigint_h);
    jpeg.addCSourceFiles(.{
        .root = libjpeg_dep.path("."),
        .files = &jpeg_sources,
        .flags = &.{},
    });
    jpeg.addIncludePath(b.path("src"));
    jpeg.addIncludePath(libjpeg_dep.path("."));
    jpeg.installHeader(libjpeg_dep.path("jpeglib.h"), "jpeglib.h");
    jpeg.installConfigHeader(jconfig_h);
    b.installArtifact(jpeg);

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
} ++ jpeg16_sources;

const arith_enc_dec = [_][]const u8{
    "jaricom.c",
    "jcarith.c",
    "jdarith.c",
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
} ++ jpeg12_sources ++ arith_enc_dec;
