const std = @import("std");

fn boolToOpt(b: bool) ?bool {
    return if (b) true else null;
}

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const is_bsd = target.isDragonFlyBSD() or
        target.isFreeBSD() or
        target.isNetBSD() or
        target.isOpenBSD();

    const is_unix = is_bsd or
        target.isDarwin() or
        target.isLinux();

    // const is_freestanding = (target.getOsTag() == .freestanding);

    const use_nls = b.option(bool, "nls", "Define to 1 if translation of program messages to the user's native language is requested.") orelse false;

    const flex_config = .{
        // actually used:
        .ENABLE_NLS = boolToOpt(use_nls),
        .M4 = "m4",
        .VERSION = "2.6.4",

        // Probably also used:
        .@"const" = null,
        .malloc = null,
        .pid_t = null,
        .realloc = null,
        .size_t = null,
        .vfork = null,

        // from config.h (default configure, linux):
        .YYTEXT_POINTER = boolToOpt(true),
        .STDC_HEADERS = boolToOpt(true),

        .PACKAGE = "flex",
        .PACKAGE_BUGREPORT = "flex-help@lists.sourceforge.net",
        .PACKAGE_NAME = "the fast lexical analyser generator",
        .PACKAGE_STRING = "the fast lexical analyser generator 2.6.4",
        .PACKAGE_TARNAME = "flex",
        .PACKAGE_URL = "",
        .PACKAGE_VERSION = "2.6.4",

        .HAVE__BOOL = boolToOpt(true),
        .HAVE_ALLOCA = boolToOpt(true),
        .HAVE_ALLOCA_H = boolToOpt(true),
        .HAVE_DCGETTEXT = boolToOpt(true),
        .HAVE_DLFCN_H = boolToOpt(true),
        .HAVE_DUP2 = boolToOpt(true),
        .HAVE_FORK = boolToOpt(true),
        .HAVE_GETTEXT = boolToOpt(true),
        .HAVE_INTTYPES_H = boolToOpt(true),
        .HAVE_LIBINTL_H = boolToOpt(true),
        .HAVE_LIBM = boolToOpt(true),
        .HAVE_LIMITS_H = boolToOpt(true),
        .HAVE_LOCALE_H = boolToOpt(true),
        .HAVE_MALLOC = boolToOpt(true),
        .HAVE_MALLOC_H = boolToOpt(true),
        .HAVE_MEMORY_H = boolToOpt(true),
        .HAVE_MEMSET = boolToOpt(true),
        .HAVE_NETINET_IN_H = boolToOpt(is_unix),
        .HAVE_POW = boolToOpt(true),
        .HAVE_PTHREAD_H = boolToOpt(true),
        .HAVE_REALLOC = boolToOpt(true),
        .HAVE_REALLOCARRAY = boolToOpt(is_bsd),
        .HAVE_REGCOMP = boolToOpt(true),
        .HAVE_REGEX_H = boolToOpt(true),
        .HAVE_SETLOCALE = boolToOpt(true),
        .HAVE_STDBOOL_H = boolToOpt(true),
        .HAVE_STDINT_H = boolToOpt(true),
        .HAVE_STDLIB_H = boolToOpt(true),
        .HAVE_STRCASECMP = boolToOpt(true),
        .HAVE_STRCHR = boolToOpt(true),
        .HAVE_STRDUP = boolToOpt(true),
        .HAVE_STRING_H = boolToOpt(true),
        .HAVE_STRINGS_H = boolToOpt(true),
        .HAVE_STRTOL = boolToOpt(true),
        .HAVE_SYS_STAT_H = boolToOpt(is_unix),
        .HAVE_SYS_TYPES_H = boolToOpt(is_unix),
        .HAVE_SYS_WAIT_H = boolToOpt(is_unix),
        .HAVE_UNISTD_H = boolToOpt(true),
        .HAVE_VFORK = boolToOpt(true),
        .HAVE_WORKING_FORK = boolToOpt(true),
        .HAVE_WORKING_VFORK = boolToOpt(true),

        // Defined in config.h.in, but not used anywhere:
        .CRAY_STACKSEG_END = null,
        .C_ALLOCA = null,
        .HAVE_AVAILABLE_ = null,
        .HAVE_BY = null,
        .HAVE_CFLOCALECOPYCURRENT = null,
        .HAVE_CFPREFERENCESCOPYAPPVALUE = null,
        .HAVE_DNL = null,
        .HAVE_ENABLED = null,
        .HAVE_FUNCTION_ = null,
        .HAVE_HAVE = null,
        .HAVE_ICONV = null,
        .HAVE_IF = null,
        .HAVE_IS = null,
        .HAVE_NEEDED = null,
        .HAVE_NLS = null,
        .HAVE_NOT = null,
        .HAVE_ONLY = null,
        .HAVE_OPENBSD = null,
        .HAVE_REPLACEMENT = null,
        .HAVE_USED = null,
        .HAVE_VFORK_H = null,
        .HAVE_WE = null,
        .LT_OBJDIR = null,
        .STACK_DIRECTION = null,
    };

    const config_h_step = b.addConfigHeader(
        .{
            .style = .{ .autoconf = .{ .path = "./flex-2.6.4/src/config.h.in" } },
        },
        flex_config,
    );
    const config_h = config_h_step.getOutput();

    const exe = b.addExecutable(.{
        .name = "flex",
        .optimize = optimize,
        .target = target,
    });

    exe.defineCMacro("HAVE_CONFIG_H", null);

    exe.addIncludePath(BuildHelper.dirname(config_h));
    exe.addCSourceFiles(&flex_sources, &.{});

    // exe.addCSourceFiles(&lib_sources, &.{});

    exe.linkLibC();

    b.installArtifact(exe);
}

const flex_sources = [_][]const u8{
    "flex-2.6.4/src/tblcmp.c",
    "flex-2.6.4/src/parse.c",
    "flex-2.6.4/src/ecs.c",
    "flex-2.6.4/src/tables_shared.c",
    "flex-2.6.4/src/scanflags.c",
    "flex-2.6.4/src/misc.c",
    "flex-2.6.4/src/skel.c",
    "flex-2.6.4/src/yylex.c",
    "flex-2.6.4/src/gen.c",
    "flex-2.6.4/src/tables.c",
    "flex-2.6.4/src/sym.c",
    "flex-2.6.4/src/scan.c",
    "flex-2.6.4/src/scanopt.c",
    "flex-2.6.4/src/buf.c",
    "flex-2.6.4/src/regex.c",
    "flex-2.6.4/src/nfa.c",
    "flex-2.6.4/src/options.c",
    "flex-2.6.4/src/filter.c",
    "flex-2.6.4/src/ccl.c",
    "flex-2.6.4/src/main.c",
    "flex-2.6.4/src/dfa.c",
};

const BuildHelper = struct {
    pub fn dirname(path: std.Build.LazyPath) std.Build.LazyPath {
        const ComputeStep = struct {
            step: std.Build.Step,
            input: std.build.LazyPath,
            output: std.build.GeneratedFile,

            fn make(step: *std.Build.Step, progress: *std.Progress.Node) !void {
                _ = progress;

                const self = @fieldParentPtr(@This(), "step", step);

                const realpath = self.input.getPath2(step.owner, step);

                self.output.path = resolve(realpath);
            }

            fn resolve(realpath: []const u8) []const u8 {
                return std.fs.path.dirname(realpath) orelse if (std.fs.path.isAbsolute(realpath)) "/" else ".";
            }
        };

        switch (path) {
            .cwd_relative => |value| return std.Build.LazyPath{ .cwd_relative = ComputeStep.resolve(value) },
            .path => |value| return std.Build.LazyPath{ .path = ComputeStep.resolve(value) },

            .generated => |ptr| {
                const child = ptr.step.owner.allocator.create(ComputeStep) catch @panic("oom");
                child.* = ComputeStep{
                    .input = path,
                    .output = .{ .step = &child.step },
                    .step = std.Build.Step.init(.{
                        .id = .custom,
                        .name = "dirname",
                        .owner = ptr.step.owner,
                        .makeFn = ComputeStep.make,
                        .first_ret_addr = @returnAddress(),
                    }),
                };
                path.addStepDependencies(&child.step);
                return std.Build.LazyPath{ .generated = &child.output };
            },
        }
    }
};
