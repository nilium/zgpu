const std = @import("std");
const emscripten = @import("builtin").target.os.tag == .emscripten;
const zgpu_options = @import("zgpu.zig").zgpu_options;
const wgpu_common = @import("wgpu_common");

test "extern struct ABI compatibility" {
    @setEvalBranchQuota(10_000);
    const wgpu = @import("cwgpu");
    inline for (comptime std.meta.declarations(@This())) |decl| {
        const ZigType = @field(@This(), decl.name);
        if (@TypeOf(ZigType) != type) {
            continue;
        }
        if (comptime std.meta.activeTag(@typeInfo(ZigType)) == .@"struct" and
            @typeInfo(ZigType).@"struct".layout == .@"extern")
        {
            const wgpu_name = "WGPU" ++ decl.name;
            const CType = @field(wgpu, wgpu_name);
            std.testing.expectEqual(@sizeOf(CType), @sizeOf(ZigType)) catch |err| {
                std.log.err("@sizeOf({s}) != @sizeOf({s})", .{ wgpu_name, decl.name });
                return err;
            };
            inline for (comptime std.meta.fieldNames(CType), 0..) |c_field_name, nth| {
                const zig_field = std.meta.fields(ZigType)[nth];
                std.testing.expectEqual(
                    @offsetOf(CType, c_field_name),
                    @offsetOf(ZigType, zig_field.name),
                ) catch |err| {
                    std.log.err(
                        "@offsetOf({s}, {s}) != @offsetOf({s}, {s})",
                        .{ wgpu_name, c_field_name, decl.name, std.meta.fieldNames(ZigType)[nth] },
                    );
                    return err;
                };
            }
        }
    }
}

pub const Flags = u64;
pub const Bool = u32;
pub const Proc = *const fn () callconv(.c) void;

pub const StringView = extern struct {
    data: ?[*]const u8,
    length: usize,
};

pub const ChainedStruct = extern struct {
    next: ?*const ChainedStruct,
    s_type: SType,
};

// Indicates no array layer count is specified. For more info,
// see @ref SentinelValues and the places that use this sentinel value.
pub const ArrayLayerCountUndefined = std.math.maxInt(u32);
// Indicates no copy stride is specified. For more info,
// see @ref SentinelValues and the places that use this sentinel value.
pub const CopyStrideUndefined = std.math.maxInt(u32);
// Indicates no depth clear value is specified. For more info,
// see @ref SentinelValues and the places that use this sentinel value.
pub const DepthClearValueUndefined = std.math.nan(f64);
// Indicates no depth slice is specified. For more info,
// see @ref SentinelValues and the places that use this sentinel value.
pub const DepthSliceUndefined = std.math.maxInt(u32);
// For `uint32_t` limits, indicates no limit value is specified. For more info,
// see @ref SentinelValues and the places that use this sentinel value.
pub const LimitU32Undefined = std.math.maxInt(u32);
// For `uint64_t` limits, indicates no limit value is specified. For more info,
// see @ref SentinelValues and the places that use this sentinel value.
pub const LimitU64Undefined = std.math.maxInt(u64);
// Indicates no mip level count is specified. For more info,
// see @ref SentinelValues and the places that use this sentinel value.
pub const MipLevelCountUndefined = std.math.maxInt(u32);
// Indicates no query set index is specified. For more info,
// see @ref SentinelValues and the places that use this sentinel value.
pub const QuerySetIndexUndefined = std.math.maxInt(u32);
// Sentinel value used in @ref WGPUStringView to indicate that the pointer
// is to a null-terminated string, rather than an explicitly-sized string.
pub const Strlen = std.math.maxInt(usize);
// Indicates a size extending to the end of the buffer. For more info,
// see @ref SentinelValues and the places that use this sentinel value.
pub const WholeMapSize = std.math.maxInt(usize);
// Indicates a size extending to the end of the buffer. For more info,
// see @ref SentinelValues and the places that use this sentinel value.
pub const WholeSize = std.math.maxInt(u64);

pub const AdapterType = enum(u32) {
    discrete_gpu = 0x00000001,
    integrated_gpu = 0x00000002,
    cpu = 0x00000003,
    unknown = 0x00000004,
};

pub const AddressMode = enum(u32) {
    // Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000000,
    clamp_to_edge = 0x00000001,
    repeat = 0x00000002,
    mirror_repeat = 0x00000003,
};

pub const BackendType = enum(u32) {
    // Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000000,
    nul = 0x00000001,
    web_gpu = 0x00000002,
    d3d11 = 0x00000003,
    d3d12 = 0x00000004,
    metal = 0x00000005,
    vulkan = 0x00000006,
    open_gl = 0x00000007,
    open_gles = 0x00000008,
};

pub const BlendFactor = enum(u32) {
    // Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000000,
    zero = 0x00000001,
    one = 0x00000002,
    src = 0x00000003,
    one_minus_src = 0x00000004,
    src_alpha = 0x00000005,
    one_minus_src_alpha = 0x00000006,
    dst = 0x00000007,
    one_minus_dst = 0x00000008,
    dst_alpha = 0x00000009,
    one_minus_dst_alpha = 0x0000000A,
    src_alpha_saturated = 0x0000000B,
    constant = 0x0000000C,
    one_minus_constant = 0x0000000D,
    src1 = 0x0000000E,
    one_minus_src1 = 0x0000000F,
    src1_alpha = 0x00000010,
    one_minus_src1_alpha = 0x00000011,
};

pub const BlendOperation = enum(u32) {
    // Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000000,
    add = 0x00000001,
    subtract = 0x00000002,
    reverse_subtract = 0x00000003,
    min = 0x00000004,
    max = 0x00000005,
};

pub const BufferBindingType = enum(u32) {
    // Indicates that this @ref WGPUBufferBindingLayout member of
    // its parent @ref WGPUBindGroupLayoutEntry is not used.
    // (See also @ref SentinelValues.)
    binding_not_used = 0x00000000,
    // `1`. Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000001,
    uniform = 0x00000002,
    storage = 0x00000003,
    read_only_storage = 0x00000004,
};

pub const BufferMapState = enum(u32) {
    unmapped = 0x00000001,
    pending = 0x00000002,
    mapped = 0x00000003,
};

// The callback mode controls how a callback for an asynchronous operation may be fired. See @ref Asynchronous-Operations for how these are used.
pub const CallbackMode = enum(u32) {
    // Callbacks created with `WGPUCallbackMode_WaitAnyOnly`:
    // - fire when the asynchronous operation's future is passed to a call to @ref wgpuInstanceWaitAny
    //   AND the operation has already completed or it completes inside the call to @ref wgpuInstanceWaitAny.
    wait_any_only = 0x00000001,
    // Callbacks created with `WGPUCallbackMode_AllowProcessEvents`:
    // - fire for the same reasons as callbacks created with `WGPUCallbackMode_WaitAnyOnly`
    // - fire inside a call to @ref wgpuInstanceProcessEvents if the asynchronous operation is complete.
    allow_process_events = 0x00000002,
    // Callbacks created with `WGPUCallbackMode_AllowSpontaneous`:
    // - fire for the same reasons as callbacks created with `WGPUCallbackMode_AllowProcessEvents`
    // - **may** fire spontaneously on an arbitrary or application thread, when the WebGPU implementations discovers that the asynchronous operation is complete.
    //
    //   Implementations _should_ fire spontaneous callbacks as soon as possible.
    //
    // @note Because spontaneous callbacks may fire at an arbitrary time on an arbitrary thread, applications should take extra care when acquiring locks or mutating state inside the callback. It undefined behavior to re-entrantly call into the webgpu.h API if the callback fires while inside the callstack of another webgpu.h function that is not `wgpuInstanceWaitAny` or `wgpuInstanceProcessEvents`.
    allow_spontaneous = 0x00000003,
};

pub const CompareFunction = enum(u32) {
    // Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000000,
    never = 0x00000001,
    less = 0x00000002,
    equal = 0x00000003,
    less_equal = 0x00000004,
    greater = 0x00000005,
    not_equal = 0x00000006,
    greater_equal = 0x00000007,
    always = 0x00000008,
};

pub const CompilationInfoRequestStatus = enum(u32) {
    success = 0x00000001,
    // See @ref CallbackStatuses.
    callback_cancelled = 0x00000002,
};

pub const CompilationMessageType = enum(u32) {
    err = 0x00000001,
    warning = 0x00000002,
    info = 0x00000003,
};

pub const ComponentSwizzle = enum(u32) {
    // Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000000,
    // Force its value to 0.
    zero = 0x00000001,
    // Force its value to 1.
    one = 0x00000002,
    // Take its value from the red channel of the texture.
    r = 0x00000003,
    // Take its value from the green channel of the texture.
    g = 0x00000004,
    // Take its value from the blue channel of the texture.
    b = 0x00000005,
    // Take its value from the alpha channel of the texture.
    a = 0x00000006,
};

// Describes how frames are composited with other contents on the screen when @ref wgpuSurfacePresent is called.
pub const CompositeAlphaMode = enum(u32) {
    // Lets the WebGPU implementation choose the best mode (supported, and with the best performance) between @ref WGPUCompositeAlphaMode_Opaque or @ref WGPUCompositeAlphaMode_Inherit.
    auto = 0x00000000,
    // The alpha component of the image is ignored and teated as if it is always 1.0.
    opaque_ = 0x00000001,
    // The alpha component is respected and non-alpha components are assumed to be already multiplied with the alpha component. For example, (0.5, 0, 0, 0.5) is semi-transparent bright red.
    premultiplied = 0x00000002,
    // The alpha component is respected and non-alpha components are assumed to NOT be already multiplied with the alpha component. For example, (1.0, 0, 0, 0.5) is semi-transparent bright red.
    unpremultiplied = 0x00000003,
    // The handling of the alpha component is unknown to WebGPU and should be handled by the application using system-specific APIs. This mode may be unavailable (for example on Wasm).
    inherit = 0x00000004,
};

pub const CreatePipelineAsyncStatus = enum(u32) {
    success = 0x00000001,
    // See @ref CallbackStatuses.
    callback_cancelled = 0x00000002,
    validation_error = 0x00000003,
    internal_error = 0x00000004,
};

pub const CullMode = enum(u32) {
    // Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000000,
    none = 0x00000001,
    front = 0x00000002,
    back = 0x00000003,
};

pub const DeviceLostReason = enum(u32) {
    unknown = 0x00000001,
    destroyed = 0x00000002,
    // See @ref CallbackStatuses.
    callback_cancelled = 0x00000003,
    failed_creation = 0x00000004,
};

pub const ErrorFilter = enum(u32) {
    validation = 0x00000001,
    out_of_memory = 0x00000002,
    internal = 0x00000003,
};

pub const ErrorType = enum(u32) {
    no_error = 0x00000001,
    validation = 0x00000002,
    out_of_memory = 0x00000003,
    internal = 0x00000004,
    unknown = 0x00000005,
};

// See @ref WGPURequestAdapterOptions::featureLevel.
pub const FeatureLevel = enum(u32) {
    // Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000000,
    // "Compatibility" profile which can be supported on OpenGL ES 3.1 and D3D11.
    compatibility = 0x00000001,
    // "Core" profile which can be supported on Vulkan/Metal/D3D12 (at least).
    core = 0x00000002,
};

pub const FeatureName = enum(u32) {
    core_features_and_limits = 0x00000001,
    depth_clip_control = 0x00000002,
    depth32_float_stencil8 = 0x00000003,
    texture_compression_bc = 0x00000004,
    texture_compression_bc_sliced_3d = 0x00000005,
    texture_compression_etc2 = 0x00000006,
    texture_compression_astc = 0x00000007,
    texture_compression_astc_sliced_3d = 0x00000008,
    timestamp_query = 0x00000009,
    indirect_first_instance = 0x0000000A,
    shader_f16 = 0x0000000B,
    rg11b10_ufloat_renderable = 0x0000000C,
    bgra8_unorm_storage = 0x0000000D,
    float32_filterable = 0x0000000E,
    float32_blendable = 0x0000000F,
    clip_distances = 0x00000010,
    dual_source_blending = 0x00000011,
    subgroups = 0x00000012,
    texture_formats_tier_1 = 0x00000013,
    texture_formats_tier_2 = 0x00000014,
    primitive_index = 0x00000015,
    texture_component_swizzle = 0x00000016,
};

pub const FilterMode = enum(u32) {
    // Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000000,
    nearest = 0x00000001,
    linear = 0x00000002,
};

pub const FrontFace = enum(u32) {
    // Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000000,
    ccw = 0x00000001,
    cw = 0x00000002,
};

pub const IndexFormat = enum(u32) {
    // Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000000,
    uint16 = 0x00000001,
    uint32 = 0x00000002,
};

pub const InstanceFeatureName = enum(u32) {
    // Enable use of ::wgpuInstanceWaitAny with `timeoutNS > 0`.
    timed_wait_any = 0x00000001,
    // Enable passing SPIR-V shaders to @ref wgpuDeviceCreateShaderModule,
    // via @ref WGPUShaderSourceSPIRV.
    shader_source_spirv = 0x00000002,
    // Normally, a @ref WGPUAdapter can only create a single device. If this is
    // available and enabled, then adapters won't immediately expire when they
    // create a device, so can be reused to make multiple devices. They may
    // still expire for other reasons.
    multiple_devices_per_adapter = 0x00000003,
};

pub const LoadOp = enum(u32) {
    // Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000000,
    load = 0x00000001,
    clear = 0x00000002,
};

pub const MapAsyncStatus = enum(u32) {
    success = 0x00000001,
    // See @ref CallbackStatuses.
    callback_cancelled = 0x00000002,
    err = 0x00000003,
    aborted = 0x00000004,
};

pub const MipmapFilterMode = enum(u32) {
    // Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000000,
    nearest = 0x00000001,
    linear = 0x00000002,
};

pub const OptionalBool = enum(u32) {
    false = 0x00000000,
    true = 0x00000001,
    undef = 0x00000002,
};

pub const PopErrorScopeStatus = enum(u32) {
    // The error scope stack was successfully popped and a result was reported.
    success = 0x00000001,
    // See @ref CallbackStatuses.
    callback_cancelled = 0x00000002,
    // The error scope stack could not be popped, because it was empty.
    err = 0x00000003,
};

pub const PowerPreference = enum(u32) {
    // No preference. (See also @ref SentinelValues.)
    undef = 0x00000000,
    low_power = 0x00000001,
    high_performance = 0x00000002,
};

pub const PredefinedColorSpace = enum(u32) {
    srgb = 0x00000001,
    display_p3 = 0x00000002,
};

// Describes when and in which order frames are presented on the screen when @ref wgpuSurfacePresent is called.
pub const PresentMode = enum(u32) {
    // Present mode is not specified. Use the default.
    undef = 0x00000000,
    // The presentation of the image to the user waits for the next vertical blanking period to update in a first-in, first-out manner.
    // Tearing cannot be observed and frame-loop will be limited to the display's refresh rate.
    // This is the only mode that's always available.
    fifo = 0x00000001,
    // The presentation of the image to the user tries to wait for the next vertical blanking period but may decide to not wait if a frame is presented late.
    // Tearing can sometimes be observed but late-frame don't produce a full-frame stutter in the presentation.
    // This is still a first-in, first-out mechanism so a frame-loop will be limited to the display's refresh rate.
    fifo_relaxed = 0x00000002,
    // The presentation of the image to the user is updated immediately without waiting for a vertical blank.
    // Tearing can be observed but latency is minimized.
    immediate = 0x00000003,
    // The presentation of the image to the user waits for the next vertical blanking period to update to the latest provided image.
    // Tearing cannot be observed and a frame-loop is not limited to the display's refresh rate.
    mailbox = 0x00000004,
};

pub const PrimitiveTopology = enum(u32) {
    // Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000000,
    point_list = 0x00000001,
    line_list = 0x00000002,
    line_strip = 0x00000003,
    triangle_list = 0x00000004,
    triangle_strip = 0x00000005,
};

pub const QueryType = enum(u32) {
    occlusion = 0x00000001,
    timestamp = 0x00000002,
};

pub const QueueWorkDoneStatus = enum(u32) {
    success = 0x00000001,
    // See @ref CallbackStatuses.
    callback_cancelled = 0x00000002,
    // There was some deterministic error. (Note this is currently never used,
    // but it will be relevant when it's possible to create a queue object.)
    err = 0x00000003,
};

pub const RequestAdapterStatus = enum(u32) {
    success = 0x00000001,
    // See @ref CallbackStatuses.
    callback_cancelled = 0x00000002,
    unavailable = 0x00000003,
    err = 0x00000004,
};

pub const RequestDeviceStatus = enum(u32) {
    success = 0x00000001,
    // See @ref CallbackStatuses.
    callback_cancelled = 0x00000002,
    err = 0x00000003,
};

pub const SType = enum(u32) {
    shader_source_spirv = 0x00000001,
    shader_source_wgsl = 0x00000002,
    render_pass_max_draw_count = 0x00000003,
    surface_source_metal_layer = 0x00000004,
    surface_source_windows_hwnd = 0x00000005,
    surface_source_xlib_window = 0x00000006,
    surface_source_wayland_surface = 0x00000007,
    surface_source_android_native_window = 0x00000008,
    surface_source_xcb_window = 0x00000009,
    surface_color_management = 0x0000000A,
    request_adapter_web_xr_options = 0x0000000B,
    texture_component_swizzle_descriptor = 0x0000000C,
    external_texture_binding_layout = 0x0000000D,
    external_texture_binding_entry = 0x0000000E,
    compatibility_mode_limits = 0x0000000F,
    texture_binding_view_dimension = 0x00000010,
};

pub const SamplerBindingType = enum(u32) {
    // Indicates that this @ref WGPUSamplerBindingLayout member of
    // its parent @ref WGPUBindGroupLayoutEntry is not used.
    // (See also @ref SentinelValues.)
    binding_not_used = 0x00000000,
    // `1`. Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000001,
    filtering = 0x00000002,
    non_filtering = 0x00000003,
    comparison = 0x00000004,
};

// Status code returned (synchronously) from many operations. Generally
// indicates an invalid input like an unknown enum value or @ref OutStructChainError.
// Read the function's documentation for specific error conditions.
pub const Status = enum(u32) {
    success = 0x00000001,
    err = 0x00000002,
};

pub const StencilOperation = enum(u32) {
    // Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000000,
    keep = 0x00000001,
    zero = 0x00000002,
    replace = 0x00000003,
    invert = 0x00000004,
    increment_clamp = 0x00000005,
    decrement_clamp = 0x00000006,
    increment_wrap = 0x00000007,
    decrement_wrap = 0x00000008,
};

pub const StorageTextureAccess = enum(u32) {
    // Indicates that this @ref WGPUStorageTextureBindingLayout member of
    // its parent @ref WGPUBindGroupLayoutEntry is not used.
    // (See also @ref SentinelValues.)
    binding_not_used = 0x00000000,
    // `1`. Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000001,
    write_only = 0x00000002,
    read_only = 0x00000003,
    read_write = 0x00000004,
};

pub const StoreOp = enum(u32) {
    // Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000000,
    store = 0x00000001,
    discard = 0x00000002,
};

// The status enum for @ref wgpuSurfaceGetCurrentTexture.
pub const SurfaceGetCurrentTextureStatus = enum(u32) {
    // Yay! Everything is good and we can render this frame.
    success_optimal = 0x00000001,
    // Still OK - the surface can present the frame, but in a suboptimal way. The surface may need reconfiguration.
    success_suboptimal = 0x00000002,
    // Some operation timed out while trying to acquire the frame.
    timeout = 0x00000003,
    // The surface is too different to be used, compared to when it was originally created.
    outdated = 0x00000004,
    // The connection to whatever owns the surface was lost, or generally needs to be fully reinitialized.
    lost = 0x00000005,
    // There was some deterministic error (for example, the surface is not configured, or there was an @ref OutStructChainError). Should produce @ref ImplementationDefinedLogging containing details.
    err = 0x00000006,
};

pub const TextureAspect = enum(u32) {
    // Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000000,
    all = 0x00000001,
    stencil_only = 0x00000002,
    depth_only = 0x00000003,
};

pub const TextureDimension = enum(u32) {
    // Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000000,
    dim_1d = 0x00000001,
    dim_2d = 0x00000002,
    dim_3d = 0x00000003,
};

pub const TextureFormat = enum(u32) {
    // Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000000,
    r8_unorm = 0x00000001,
    r8_snorm = 0x00000002,
    r8_uint = 0x00000003,
    r8_sint = 0x00000004,
    r16_unorm = 0x00000005,
    r16_snorm = 0x00000006,
    r16_uint = 0x00000007,
    r16_sint = 0x00000008,
    r16_float = 0x00000009,
    rg8_unorm = 0x0000000A,
    rg8_snorm = 0x0000000B,
    rg8_uint = 0x0000000C,
    rg8_sint = 0x0000000D,
    r32_float = 0x0000000E,
    r32_uint = 0x0000000F,
    r32_sint = 0x00000010,
    rg16_unorm = 0x00000011,
    rg16_snorm = 0x00000012,
    rg16_uint = 0x00000013,
    rg16_sint = 0x00000014,
    rg16_float = 0x00000015,
    rgba8_unorm = 0x00000016,
    rgba8_unorm_srgb = 0x00000017,
    rgba8_snorm = 0x00000018,
    rgba8_uint = 0x00000019,
    rgba8_sint = 0x0000001A,
    bgra8_unorm = 0x0000001B,
    bgra8_unorm_srgb = 0x0000001C,
    rgb10_a2_uint = 0x0000001D,
    rgb10_a2_unorm = 0x0000001E,
    rg11_b10_ufloat = 0x0000001F,
    rgb9_e5_ufloat = 0x00000020,
    rg32_float = 0x00000021,
    rg32_uint = 0x00000022,
    rg32_sint = 0x00000023,
    rgba16_unorm = 0x00000024,
    rgba16_snorm = 0x00000025,
    rgba16_uint = 0x00000026,
    rgba16_sint = 0x00000027,
    rgba16_float = 0x00000028,
    rgba32_float = 0x00000029,
    rgba32_uint = 0x0000002A,
    rgba32_sint = 0x0000002B,
    stencil8 = 0x0000002C,
    depth16_unorm = 0x0000002D,
    depth24_plus = 0x0000002E,
    depth24_plus_stencil8 = 0x0000002F,
    depth32_float = 0x00000030,
    depth32_float_stencil8 = 0x00000031,
    bc1_rgba_unorm = 0x00000032,
    bc1_rgba_unorm_srgb = 0x00000033,
    bc2_rgba_unorm = 0x00000034,
    bc2_rgba_unorm_srgb = 0x00000035,
    bc3_rgba_unorm = 0x00000036,
    bc3_rgba_unorm_srgb = 0x00000037,
    bc4_r_unorm = 0x00000038,
    bc4_r_snorm = 0x00000039,
    bc5_rg_unorm = 0x0000003A,
    bc5_rg_snorm = 0x0000003B,
    bc6h_rgb_ufloat = 0x0000003C,
    bc6h_rgb_float = 0x0000003D,
    bc7_rgba_unorm = 0x0000003E,
    bc7_rgba_unorm_srgb = 0x0000003F,
    etc2_rgb8_unorm = 0x00000040,
    etc2_rgb8_unorm_srgb = 0x00000041,
    etc2_rgb8a1_unorm = 0x00000042,
    etc2_rgb8a1_unorm_srgb = 0x00000043,
    etc2_rgba8_unorm = 0x00000044,
    etc2_rgba8_unorm_srgb = 0x00000045,
    eac_r11_unorm = 0x00000046,
    eac_r11_snorm = 0x00000047,
    eac_rg11_unorm = 0x00000048,
    eac_rg11_snorm = 0x00000049,
    astc_4x4_unorm = 0x0000004A,
    astc_4x4_unorm_srgb = 0x0000004B,
    astc_5x4_unorm = 0x0000004C,
    astc_5x4_unorm_srgb = 0x0000004D,
    astc_5x5_unorm = 0x0000004E,
    astc_5x5_unorm_srgb = 0x0000004F,
    astc_6x5_unorm = 0x00000050,
    astc_6x5_unorm_srgb = 0x00000051,
    astc_6x6_unorm = 0x00000052,
    astc_6x6_unorm_srgb = 0x00000053,
    astc_8x5_unorm = 0x00000054,
    astc_8x5_unorm_srgb = 0x00000055,
    astc_8x6_unorm = 0x00000056,
    astc_8x6_unorm_srgb = 0x00000057,
    astc_8x8_unorm = 0x00000058,
    astc_8x8_unorm_srgb = 0x00000059,
    astc_10x5_unorm = 0x0000005A,
    astc_10x5_unorm_srgb = 0x0000005B,
    astc_10x6_unorm = 0x0000005C,
    astc_10x6_unorm_srgb = 0x0000005D,
    astc_10x8_unorm = 0x0000005E,
    astc_10x8_unorm_srgb = 0x0000005F,
    astc_10x10_unorm = 0x00000060,
    astc_10x10_unorm_srgb = 0x00000061,
    astc_12x10_unorm = 0x00000062,
    astc_12x10_unorm_srgb = 0x00000063,
    astc_12x12_unorm = 0x00000064,
    astc_12x12_unorm_srgb = 0x00000065,
};

pub const TextureSampleType = enum(u32) {
    // Indicates that this @ref WGPUTextureBindingLayout member of
    // its parent @ref WGPUBindGroupLayoutEntry is not used.
    // (See also @ref SentinelValues.)
    binding_not_used = 0x00000000,
    // `1`. Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000001,
    float = 0x00000002,
    unfilterable_float = 0x00000003,
    depth = 0x00000004,
    sint = 0x00000005,
    uint = 0x00000006,
};

pub const TextureViewDimension = enum(u32) {
    // Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000000,
    dim_1d = 0x00000001,
    dim_2d = 0x00000002,
    dim_2d_array = 0x00000003,
    cube = 0x00000004,
    cube_array = 0x00000005,
    dim_3d = 0x00000006,
};

pub const ToneMappingMode = enum(u32) {
    standard = 0x00000001,
    extended = 0x00000002,
};

pub const VertexFormat = enum(u32) {
    uint8 = 0x00000001,
    uint8x2 = 0x00000002,
    uint8x4 = 0x00000003,
    sint8 = 0x00000004,
    sint8x2 = 0x00000005,
    sint8x4 = 0x00000006,
    unorm8 = 0x00000007,
    unorm8x2 = 0x00000008,
    unorm8x4 = 0x00000009,
    snorm8 = 0x0000000A,
    snorm8x2 = 0x0000000B,
    snorm8x4 = 0x0000000C,
    uint16 = 0x0000000D,
    uint16x2 = 0x0000000E,
    uint16x4 = 0x0000000F,
    sint16 = 0x00000010,
    sint16x2 = 0x00000011,
    sint16x4 = 0x00000012,
    unorm16 = 0x00000013,
    unorm16x2 = 0x00000014,
    unorm16x4 = 0x00000015,
    snorm16 = 0x00000016,
    snorm16x2 = 0x00000017,
    snorm16x4 = 0x00000018,
    float16 = 0x00000019,
    float16x2 = 0x0000001A,
    float16x4 = 0x0000001B,
    float32 = 0x0000001C,
    float32x2 = 0x0000001D,
    float32x3 = 0x0000001E,
    float32x4 = 0x0000001F,
    uint32 = 0x00000020,
    uint32x2 = 0x00000021,
    uint32x3 = 0x00000022,
    uint32x4 = 0x00000023,
    sint32 = 0x00000024,
    sint32x2 = 0x00000025,
    sint32x3 = 0x00000026,
    sint32x4 = 0x00000027,
    unorm10_10_10_2 = 0x00000028,
    unorm8x4_bgra = 0x00000029,
};

pub const VertexStepMode = enum(u32) {
    // Indicates no value is passed for this argument. See @ref SentinelValues.
    undef = 0x00000000,
    vertex = 0x00000001,
    instance = 0x00000002,
};

// Status returned from a call to ::wgpuInstanceWaitAny.
pub const WaitStatus = enum(u32) {
    // At least one WGPUFuture completed successfully.
    success = 0x00000001,
    // The wait operation succeeded, but no WGPUFutures completed within the timeout.
    timed_out = 0x00000002,
    // The call was invalid for some reason (see @ref Wait-Any).
    // Should produce @ref ImplementationDefinedLogging containing details.
    err = 0x00000003,
};

pub const WGSLLanguageFeatureName = enum(u32) {
    readonly_and_readwrite_storage_textures = 0x00000001,
    packed4x8_integer_dot_product = 0x00000002,
    unrestricted_pointer_parameters = 0x00000003,
    pointer_composite_access = 0x00000004,
    uniform_buffer_standard_layout = 0x00000005,
    subgroup_id = 0x00000006,
    texture_and_sampler_let = 0x00000007,
    subgroup_uniformity = 0x00000008,
    texture_formats_tier1 = 0x00000009,
    linear_indexing = 0x0000000A,
    immediate_address_space = 0x0000000B,
};

pub const BufferUsage = Flags;
pub const BufferUsage_none: BufferUsage = 0x0000000000000000;
// The buffer can be *mapped* on the CPU side in *read* mode (using @ref WGPUMapMode_Read).
pub const BufferUsage_map_read: BufferUsage = 0x0000000000000001;
// The buffer can be *mapped* on the CPU side in *write* mode (using @ref WGPUMapMode_Write).
//
// @note This usage is **not** required to set `mappedAtCreation` to `true` in @ref WGPUBufferDescriptor.
pub const BufferUsage_map_write: BufferUsage = 0x0000000000000002;
// The buffer can be used as the *source* of a GPU-side copy operation.
pub const BufferUsage_copy_src: BufferUsage = 0x0000000000000004;
// The buffer can be used as the *destination* of a GPU-side copy operation.
pub const BufferUsage_copy_dst: BufferUsage = 0x0000000000000008;
// The buffer can be used as an Index buffer when doing indexed drawing in a render pipeline.
pub const BufferUsage_index: BufferUsage = 0x0000000000000010;
// The buffer can be used as a Vertex buffer when using a render pipeline.
pub const BufferUsage_vertex: BufferUsage = 0x0000000000000020;
// The buffer can be bound to a shader as a uniform buffer.
pub const BufferUsage_uniform: BufferUsage = 0x0000000000000040;
// The buffer can be bound to a shader as a storage buffer.
pub const BufferUsage_storage: BufferUsage = 0x0000000000000080;
// The buffer can store arguments for an indirect draw call.
pub const BufferUsage_indirect: BufferUsage = 0x0000000000000100;
// The buffer can store the result of a timestamp or occlusion query.
pub const BufferUsage_query_resolve: BufferUsage = 0x0000000000000200;

pub const ColorWriteMask = Flags;
pub const ColorWriteMask_none: ColorWriteMask = 0x0000000000000000;
pub const ColorWriteMask_red: ColorWriteMask = 0x0000000000000001;
pub const ColorWriteMask_green: ColorWriteMask = 0x0000000000000002;
pub const ColorWriteMask_blue: ColorWriteMask = 0x0000000000000004;
pub const ColorWriteMask_alpha: ColorWriteMask = 0x0000000000000008;
pub const ColorWriteMask_all: ColorWriteMask = 0x000000000000000F;

pub const MapMode = Flags;
pub const MapMode_none: MapMode = 0x0000000000000000;
pub const MapMode_read: MapMode = 0x0000000000000001;
pub const MapMode_write: MapMode = 0x0000000000000002;

pub const ShaderStage = Flags;
pub const ShaderStage_none: ShaderStage = 0x0000000000000000;
pub const ShaderStage_vertex: ShaderStage = 0x0000000000000001;
pub const ShaderStage_fragment: ShaderStage = 0x0000000000000002;
pub const ShaderStage_compute: ShaderStage = 0x0000000000000004;

pub const TextureUsage = Flags;
pub const TextureUsage_none: TextureUsage = 0x0000000000000000;
pub const TextureUsage_copy_src: TextureUsage = 0x0000000000000001;
pub const TextureUsage_copy_dst: TextureUsage = 0x0000000000000002;
pub const TextureUsage_texture_binding: TextureUsage = 0x0000000000000004;
pub const TextureUsage_storage_binding: TextureUsage = 0x0000000000000008;
pub const TextureUsage_render_attachment: TextureUsage = 0x0000000000000010;
pub const TextureUsage_transient_attachment: TextureUsage = 0x0000000000000020;

pub const BufferMapCallback = *const fn (status: MapAsyncStatus, message: StringView, userdata1: ?*anyopaque, userdata2: ?*anyopaque) callconv(.c) void;

pub const BufferMapCallbackInfo = extern struct {
    next_in_chain: ?*const ChainedStruct,
    mode: CallbackMode,
    callback: ?BufferMapCallback,
    userdata1: ?*anyopaque,
    userdata2: ?*anyopaque,
};

pub const CompilationInfoCallback = *const fn (status: CompilationInfoRequestStatus, compilation_info: *const CompilationInfo, userdata1: ?*anyopaque, userdata2: ?*anyopaque) callconv(.c) void;

pub const CompilationInfoCallbackInfo = extern struct {
    next_in_chain: ?*const ChainedStruct,
    mode: CallbackMode,
    callback: ?CompilationInfoCallback,
    userdata1: ?*anyopaque,
    userdata2: ?*anyopaque,
};

pub const CreateComputePipelineAsyncCallback = *const fn (status: CreatePipelineAsyncStatus, pipeline: ComputePipeline, message: StringView, userdata1: ?*anyopaque, userdata2: ?*anyopaque) callconv(.c) void;

pub const CreateComputePipelineAsyncCallbackInfo = extern struct {
    next_in_chain: ?*const ChainedStruct,
    mode: CallbackMode,
    callback: ?CreateComputePipelineAsyncCallback,
    userdata1: ?*anyopaque,
    userdata2: ?*anyopaque,
};

pub const CreateRenderPipelineAsyncCallback = *const fn (status: CreatePipelineAsyncStatus, pipeline: RenderPipeline, message: StringView, userdata1: ?*anyopaque, userdata2: ?*anyopaque) callconv(.c) void;

pub const CreateRenderPipelineAsyncCallbackInfo = extern struct {
    next_in_chain: ?*const ChainedStruct,
    mode: CallbackMode,
    callback: ?CreateRenderPipelineAsyncCallback,
    userdata1: ?*anyopaque,
    userdata2: ?*anyopaque,
};

pub const DeviceLostCallback = *const fn (device: Device, reason: DeviceLostReason, message: StringView, userdata1: ?*anyopaque, userdata2: ?*anyopaque) callconv(.c) void;

pub const DeviceLostCallbackInfo = extern struct {
    next_in_chain: ?*const ChainedStruct,
    mode: CallbackMode,
    callback: ?DeviceLostCallback,
    userdata1: ?*anyopaque,
    userdata2: ?*anyopaque,
};

pub const PopErrorScopeCallback = *const fn (status: PopErrorScopeStatus, type_: ErrorType, message: StringView, userdata1: ?*anyopaque, userdata2: ?*anyopaque) callconv(.c) void;

pub const PopErrorScopeCallbackInfo = extern struct {
    next_in_chain: ?*const ChainedStruct,
    mode: CallbackMode,
    callback: ?PopErrorScopeCallback,
    userdata1: ?*anyopaque,
    userdata2: ?*anyopaque,
};

pub const QueueWorkDoneCallback = *const fn (status: QueueWorkDoneStatus, message: StringView, userdata1: ?*anyopaque, userdata2: ?*anyopaque) callconv(.c) void;

pub const QueueWorkDoneCallbackInfo = extern struct {
    next_in_chain: ?*const ChainedStruct,
    mode: CallbackMode,
    callback: ?QueueWorkDoneCallback,
    userdata1: ?*anyopaque,
    userdata2: ?*anyopaque,
};

pub const RequestAdapterCallback = *const fn (status: RequestAdapterStatus, adapter: Adapter, message: StringView, userdata1: ?*anyopaque, userdata2: ?*anyopaque) callconv(.c) void;

pub const RequestAdapterCallbackInfo = extern struct {
    next_in_chain: ?*const ChainedStruct,
    mode: CallbackMode,
    callback: ?RequestAdapterCallback,
    userdata1: ?*anyopaque,
    userdata2: ?*anyopaque,
};

pub const RequestDeviceCallback = *const fn (status: RequestDeviceStatus, device: Device, message: StringView, userdata1: ?*anyopaque, userdata2: ?*anyopaque) callconv(.c) void;

pub const RequestDeviceCallbackInfo = extern struct {
    next_in_chain: ?*const ChainedStruct,
    mode: CallbackMode,
    callback: ?RequestDeviceCallback,
    userdata1: ?*anyopaque,
    userdata2: ?*anyopaque,
};

pub const UncapturedErrorCallback = *const fn (device: Device, type_: ErrorType, message: StringView, userdata1: ?*anyopaque, userdata2: ?*anyopaque) callconv(.c) void;

pub const UncapturedErrorCallbackInfo = extern struct {
    next_in_chain: ?*const ChainedStruct,
    callback: ?UncapturedErrorCallback,
    userdata1: ?*anyopaque,
    userdata2: ?*anyopaque,
};

pub const AdapterInfo = extern struct {
    next_in_chain: ?*const ChainedStruct,
    vendor: StringView,
    architecture: StringView,
    device: StringView,
    description: StringView,
    backend_type: BackendType,
    adapter_type: AdapterType,
    vendor_id: u32,
    device_id: u32,
    subgroup_min_size: u32,
    subgroup_max_size: u32,
};

pub const BindGroupDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct,
    label: StringView,
    layout: BindGroupLayout,
    entry_count: usize,
    entries: ?[*]const BindGroupEntry,
};

pub const BindGroupEntry = extern struct {
    next_in_chain: ?*const ChainedStruct,
    // Binding index in the bind group.
    binding: u32,
    // Set this if the binding is a buffer object.
    // Otherwise must be null.
    buffer: ?Buffer,
    // If the binding is a buffer, this is the byte offset of the binding range.
    // Otherwise ignored.
    offset: u64,
    // If the binding is a buffer, this is the byte size of the binding range
    // (@ref WGPU_WHOLE_SIZE means the binding ends at the end of the buffer).
    // Otherwise ignored.
    size: u64,
    // Set this if the binding is a sampler object.
    // Otherwise must be null.
    sampler: ?Sampler,
    // Set this if the binding is a texture view object.
    // Otherwise must be null.
    texture_view: ?TextureView,
};

pub const BindGroupLayoutDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct,
    label: StringView,
    entry_count: usize,
    entries: ?[*]const BindGroupLayoutEntry,
};

pub const BindGroupLayoutEntry = extern struct {
    next_in_chain: ?*const ChainedStruct,
    binding: u32,
    visibility: ShaderStage,
    // If non-zero, this entry defines a binding array with this size.
    binding_array_size: u32,
    buffer: BufferBindingLayout,
    sampler: SamplerBindingLayout,
    texture: TextureBindingLayout,
    storage_texture: StorageTextureBindingLayout,
};

pub const BlendComponent = extern struct {
    // If set to @ref WGPUBlendOperation_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUBlendOperation_Add.
    operation: BlendOperation,
    // If set to @ref WGPUBlendFactor_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUBlendFactor_One.
    src_factor: BlendFactor,
    // If set to @ref WGPUBlendFactor_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUBlendFactor_Zero.
    dst_factor: BlendFactor,
};

pub const BlendState = extern struct {
    color: BlendComponent,
    alpha: BlendComponent,
};

pub const BufferBindingLayout = extern struct {
    next_in_chain: ?*const ChainedStruct,
    // If set to @ref WGPUBufferBindingType_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUBufferBindingType_Uniform.
    type_: BufferBindingType,
    has_dynamic_offset: Bool,
    min_binding_size: u64,
};

pub const BufferDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct,
    label: StringView,
    usage: BufferUsage,
    size: u64,
    // When true, the buffer is mapped in write mode at creation. It should thus be unmapped once its initial data has been written.
    //
    // @note Mapping at creation does **not** require the usage @ref WGPUBufferUsage_MapWrite.
    mapped_at_creation: Bool,
};

// An RGBA color. Represents a `f32`, `i32`, or `u32` color using @ref DoubleAsSupertype.
//
// If any channel is non-finite, produces a @ref NonFiniteFloatValueError.
pub const Color = extern struct {
    r: f64,
    g: f64,
    b: f64,
    a: f64,
};

pub const ColorTargetState = extern struct {
    next_in_chain: ?*const ChainedStruct,
    // The texture format of the target. If @ref WGPUTextureFormat_Undefined,
    // indicates a "hole" in the parent @ref WGPUFragmentState `targets` array:
    // the pipeline does not output a value at this `location`.
    format: TextureFormat,
    blend: ?*const BlendState,
    write_mask: ColorWriteMask,
};

pub const CommandBufferDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct,
    label: StringView,
};

pub const CommandEncoderDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct,
    label: StringView,
};

// Note: While Compatibility Mode is optional to implement, this extension struct
// is required to be supported (for both queries and requests) and behave as
// defined in the WebGPU spec.
pub const CompatibilityModeLimits = extern struct {
    chain: ChainedStruct,
    max_storage_buffers_in_vertex_stage: u32,
    max_storage_textures_in_vertex_stage: u32,
    max_storage_buffers_in_fragment_stage: u32,
    max_storage_textures_in_fragment_stage: u32,
};

pub const CompilationInfo = extern struct {
    next_in_chain: ?*const ChainedStruct,
    message_count: usize,
    messages: ?[*]const CompilationMessage,
};

pub const CompilationMessage = extern struct {
    next_in_chain: ?*const ChainedStruct,
    // A @ref LocalizableHumanReadableMessageString.
    message: StringView,
    // Severity level of the message.
    type_: CompilationMessageType,
    // Line number where the message is attached, starting at 1.
    line_num: u64,
    // Offset in UTF-8 code units (bytes) from the beginning of the line, starting at 1.
    line_pos: u64,
    // Offset in UTF-8 code units (bytes) from the beginning of the shader code, starting at 0.
    offset: u64,
    // Length in UTF-8 code units (bytes) of the span the message corresponds to.
    length: u64,
};

pub const ComputePassDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct,
    label: StringView,
    timestamp_writes: ?*const PassTimestampWrites,
};

pub const ComputePipelineDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct,
    label: StringView,
    layout: ?PipelineLayout,
    compute: ComputeState,
};

pub const ComputeState = extern struct {
    next_in_chain: ?*const ChainedStruct,
    module: ShaderModule,
    entry_point: StringView,
    constant_count: usize,
    constants: ?[*]const ConstantEntry,
};

pub const ConstantEntry = extern struct {
    next_in_chain: ?*const ChainedStruct,
    key: StringView,
    // Represents a WGSL numeric or boolean value using @ref DoubleAsSupertype.
    //
    // If non-finite, produces a @ref NonFiniteFloatValueError.
    value: f64,
};

pub const DepthStencilState = extern struct {
    next_in_chain: ?*const ChainedStruct,
    format: TextureFormat,
    depth_write_enabled: OptionalBool,
    depth_compare: CompareFunction,
    stencil_front: StencilFaceState,
    stencil_back: StencilFaceState,
    stencil_read_mask: u32,
    stencil_write_mask: u32,
    depth_bias: i32,
    // TODO
    //
    // If non-finite, produces a @ref NonFiniteFloatValueError.
    depth_bias_slope_scale: f32,
    // TODO
    //
    // If non-finite, produces a @ref NonFiniteFloatValueError.
    depth_bias_clamp: f32,
};

pub const DeviceDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct,
    label: StringView,
    required_feature_count: usize,
    required_features: ?[*]const FeatureName,
    required_limits: ?*const Limits,
    default_queue: QueueDescriptor,
    device_lost_callback_info: DeviceLostCallbackInfo,
    // Called when there is an uncaptured error on this device, from any thread.
    // See @ref ErrorScopes.
    //
    // **Important:** This callback does not have a configurable @ref WGPUCallbackMode; it may be called at any time (like @ref WGPUCallbackMode_AllowSpontaneous). As such, calls into the `webgpu.h` API from this callback are unsafe. See @ref CallbackReentrancy.
    uncaptured_error_callback_info: UncapturedErrorCallbackInfo,
};

pub const Extent3D = extern struct {
    width: u32,
    height: u32,
    depth_or_array_layers: u32,
};

// Chained in an @ref WGPUBindGroupEntry to set it to an @ref WGPUExternalTexture. This must have a corresponding @ref WGPUExternalTextureBindingLayout in the @ref WGPUBindGroupLayout.
pub const ExternalTextureBindingEntry = extern struct {
    chain: ChainedStruct,
    external_texture: ExternalTexture,
};

// Chained in @ref WGPUBindGroupLayoutEntry to specify that the corresponding entries in an @ref WGPUBindGroup will contain an @ref WGPUExternalTexture.
pub const ExternalTextureBindingLayout = extern struct {
    chain: ChainedStruct,
};

pub const FragmentState = extern struct {
    next_in_chain: ?*const ChainedStruct,
    module: ShaderModule,
    entry_point: StringView,
    constant_count: usize,
    constants: ?[*]const ConstantEntry,
    target_count: usize,
    targets: ?[*]const ColorTargetState,
};

// Opaque handle to an asynchronous operation. See @ref Asynchronous-Operations for more information.
pub const Future = extern struct {
    // Opaque id of the @ref WGPUFuture
    id: u64,
};

// Struct holding a future to wait on, and a `completed` boolean flag.
pub const FutureWaitInfo = extern struct {
    // The future to wait on.
    future: Future,
    // Whether or not the future completed.
    completed: Bool,
};

pub const InstanceDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct,
    required_feature_count: usize,
    required_features: ?[*]const InstanceFeatureName,
    required_limits: ?*const InstanceLimits,
};

pub const InstanceLimits = extern struct {
    next_in_chain: ?*const ChainedStruct,
    // The maximum number @ref WGPUFutureWaitInfo supported in a call to ::wgpuInstanceWaitAny with `timeoutNS > 0`.
    timed_wait_any_max_count: usize,
};

pub const Limits = extern struct {
    next_in_chain: ?*const ChainedStruct,
    max_texture_dimension1d: u32,
    max_texture_dimension2d: u32,
    max_texture_dimension3d: u32,
    max_texture_array_layers: u32,
    max_bind_groups: u32,
    max_bind_groups_plus_vertex_buffers: u32,
    max_bindings_per_bind_group: u32,
    max_dynamic_uniform_buffers_per_pipeline_layout: u32,
    max_dynamic_storage_buffers_per_pipeline_layout: u32,
    max_sampled_textures_per_shader_stage: u32,
    max_samplers_per_shader_stage: u32,
    max_storage_buffers_per_shader_stage: u32,
    max_storage_textures_per_shader_stage: u32,
    max_uniform_buffers_per_shader_stage: u32,
    max_uniform_buffer_binding_size: u64,
    max_storage_buffer_binding_size: u64,
    min_uniform_buffer_offset_alignment: u32,
    min_storage_buffer_offset_alignment: u32,
    max_vertex_buffers: u32,
    max_buffer_size: u64,
    max_vertex_attributes: u32,
    max_vertex_buffer_array_stride: u32,
    max_inter_stage_shader_variables: u32,
    max_color_attachments: u32,
    max_color_attachment_bytes_per_sample: u32,
    max_compute_workgroup_storage_size: u32,
    max_compute_invocations_per_workgroup: u32,
    max_compute_workgroup_size_x: u32,
    max_compute_workgroup_size_y: u32,
    max_compute_workgroup_size_z: u32,
    max_compute_workgroups_per_dimension: u32,
    max_immediate_size: u32,
};

pub const MultisampleState = extern struct {
    next_in_chain: ?*const ChainedStruct,
    count: u32,
    mask: u32,
    alpha_to_coverage_enabled: Bool,
};

pub const Origin3D = extern struct {
    x: u32,
    y: u32,
    z: u32,
};

pub const PassTimestampWrites = extern struct {
    next_in_chain: ?*const ChainedStruct,
    // Query set to write timestamps to.
    query_set: QuerySet,
    beginning_of_pass_write_index: u32,
    end_of_pass_write_index: u32,
};

pub const PipelineLayoutDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct,
    label: StringView,
    bind_group_layout_count: usize,
    bind_group_layouts: ?[*]const BindGroupLayout,
    immediate_size: u32,
};

pub const PrimitiveState = extern struct {
    next_in_chain: ?*const ChainedStruct,
    // If set to @ref WGPUPrimitiveTopology_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUPrimitiveTopology_TriangleList.
    topology: PrimitiveTopology,
    strip_index_format: IndexFormat,
    // If set to @ref WGPUFrontFace_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUFrontFace_CCW.
    front_face: FrontFace,
    // If set to @ref WGPUCullMode_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUCullMode_None.
    cull_mode: CullMode,
    unclipped_depth: Bool,
};

pub const QuerySetDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct,
    label: StringView,
    type_: QueryType,
    count: u32,
};

pub const QueueDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct,
    label: StringView,
};

pub const RenderBundleDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct,
    label: StringView,
};

pub const RenderBundleEncoderDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct,
    label: StringView,
    color_format_count: usize,
    color_formats: ?[*]const TextureFormat,
    depth_stencil_format: TextureFormat,
    sample_count: u32,
    depth_read_only: Bool,
    stencil_read_only: Bool,
};

pub const RenderPassColorAttachment = extern struct {
    next_in_chain: ?*const ChainedStruct,
    // If `NULL`, indicates a hole in the parent
    // @ref WGPURenderPassDescriptor::colorAttachments array.
    view: ?TextureView,
    depth_slice: u32,
    resolve_target: ?TextureView,
    load_op: LoadOp,
    store_op: StoreOp,
    clear_value: Color,
};

pub const RenderPassDepthStencilAttachment = extern struct {
    next_in_chain: ?*const ChainedStruct,
    view: TextureView,
    depth_load_op: LoadOp,
    depth_store_op: StoreOp,
    // This is a @ref NullableFloatingPointType.
    //
    // If `NaN`, indicates an `undefined` value (as defined by the JS spec).
    // Use @ref WGPU_DEPTH_CLEAR_VALUE_UNDEFINED to indicate this semantically.
    //
    // If infinite, produces a @ref NonFiniteFloatValueError.
    depth_clear_value: f32,
    depth_read_only: Bool,
    stencil_load_op: LoadOp,
    stencil_store_op: StoreOp,
    stencil_clear_value: u32,
    stencil_read_only: Bool,
};

pub const RenderPassDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct,
    label: StringView,
    color_attachment_count: usize,
    color_attachments: ?[*]const RenderPassColorAttachment,
    depth_stencil_attachment: ?*const RenderPassDepthStencilAttachment,
    occlusion_query_set: ?QuerySet,
    timestamp_writes: ?*const PassTimestampWrites,
};

pub const RenderPassMaxDrawCount = extern struct {
    chain: ChainedStruct,
    max_draw_count: u64,
};

pub const RenderPipelineDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct,
    label: StringView,
    layout: ?PipelineLayout,
    vertex: VertexState,
    primitive: PrimitiveState,
    depth_stencil: ?*const DepthStencilState,
    multisample: MultisampleState,
    fragment: ?*const FragmentState,
};

pub const RequestAdapterOptions = extern struct {
    next_in_chain: ?*const ChainedStruct,
    // "Feature level" for the adapter request. If an adapter is returned, it must support the features and limits in the requested feature level.
    //
    // If set to @ref WGPUFeatureLevel_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUFeatureLevel_Core.
    // Additionally, implementations may ignore @ref WGPUFeatureLevel_Compatibility
    // and provide @ref WGPUFeatureLevel_Core instead.
    feature_level: FeatureLevel,
    power_preference: PowerPreference,
    // If true, requires the adapter to be a "fallback" adapter as defined by the JS spec.
    // If this is not possible, the request returns null.
    force_fallback_adapter: Bool,
    // If set, requires the adapter to have a particular backend type.
    // If this is not possible, the request returns null.
    backend_type: BackendType,
    // If set, requires the adapter to be able to output to a particular surface.
    // If this is not possible, the request returns null.
    compatible_surface: ?Surface,
};

// Extension providing requestAdapter options for implementations with WebXR interop (i.e. Wasm).
pub const RequestAdapterWebXROptions = extern struct {
    chain: ChainedStruct,
    // Sets the `xrCompatible` option in the JS API.
    xr_compatible: Bool,
};

pub const SamplerBindingLayout = extern struct {
    next_in_chain: ?*const ChainedStruct,
    // If set to @ref WGPUSamplerBindingType_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUSamplerBindingType_Filtering.
    type_: SamplerBindingType,
};

pub const SamplerDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct,
    label: StringView,
    // If set to @ref WGPUAddressMode_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUAddressMode_ClampToEdge.
    address_mode_u: AddressMode,
    // If set to @ref WGPUAddressMode_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUAddressMode_ClampToEdge.
    address_mode_v: AddressMode,
    // If set to @ref WGPUAddressMode_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUAddressMode_ClampToEdge.
    address_mode_w: AddressMode,
    // If set to @ref WGPUFilterMode_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUFilterMode_Nearest.
    mag_filter: FilterMode,
    // If set to @ref WGPUFilterMode_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUFilterMode_Nearest.
    min_filter: FilterMode,
    // If set to @ref WGPUFilterMode_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUMipmapFilterMode_Nearest.
    mipmap_filter: MipmapFilterMode,
    // TODO
    //
    // If non-finite, produces a @ref NonFiniteFloatValueError.
    lod_min_clamp: f32,
    // TODO
    //
    // If non-finite, produces a @ref NonFiniteFloatValueError.
    lod_max_clamp: f32,
    compare: CompareFunction,
    max_anisotropy: u16,
};

pub const ShaderModuleDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct,
    label: StringView,
};

pub const ShaderSourceSPIRV = extern struct {
    chain: ChainedStruct,
    code_size: u32,
    code: *const u32,
};

pub const ShaderSourceWGSL = extern struct {
    chain: ChainedStruct,
    code: StringView,
};

pub const StencilFaceState = extern struct {
    // If set to @ref WGPUCompareFunction_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUCompareFunction_Always.
    compare: CompareFunction,
    // If set to @ref WGPUStencilOperation_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUStencilOperation_Keep.
    fail_op: StencilOperation,
    // If set to @ref WGPUStencilOperation_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUStencilOperation_Keep.
    depth_fail_op: StencilOperation,
    // If set to @ref WGPUStencilOperation_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUStencilOperation_Keep.
    pass_op: StencilOperation,
};

pub const StorageTextureBindingLayout = extern struct {
    next_in_chain: ?*const ChainedStruct,
    // If set to @ref WGPUStorageTextureAccess_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUStorageTextureAccess_WriteOnly.
    access: StorageTextureAccess,
    format: TextureFormat,
    // If set to @ref WGPUTextureViewDimension_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUTextureViewDimension_2D.
    view_dimension: TextureViewDimension,
};

pub const SupportedFeatures = extern struct {
    feature_count: usize,
    features: ?[*]const FeatureName,
};

pub const SupportedInstanceFeatures = extern struct {
    feature_count: usize,
    features: ?[*]const InstanceFeatureName,
};

pub const SupportedWGSLLanguageFeatures = extern struct {
    feature_count: usize,
    features: ?[*]const WGSLLanguageFeatureName,
};

// Filled by @ref wgpuSurfaceGetCapabilities with what's supported for @ref wgpuSurfaceConfigure for a pair of @ref WGPUSurface and @ref WGPUAdapter.
pub const SurfaceCapabilities = extern struct {
    next_in_chain: ?*const ChainedStruct,
    // The bit set of supported @ref WGPUTextureUsage bits.
    // Guaranteed to contain @ref WGPUTextureUsage_RenderAttachment.
    usages: TextureUsage,
    // A list of supported @ref WGPUTextureFormat values, in order of preference.
    format_count: usize,
    formats: ?[*]const TextureFormat,
    // A list of supported @ref WGPUPresentMode values.
    // Guaranteed to contain @ref WGPUPresentMode_Fifo.
    present_mode_count: usize,
    present_modes: ?[*]const PresentMode,
    // A list of supported @ref WGPUCompositeAlphaMode values.
    // @ref WGPUCompositeAlphaMode_Auto will be an alias for the first element and will never be present in this array.
    alpha_mode_count: usize,
    alpha_modes: ?[*]const CompositeAlphaMode,
};

// Extension of @ref WGPUSurfaceConfiguration for color spaces and HDR.
pub const SurfaceColorManagement = extern struct {
    chain: ChainedStruct,
    color_space: PredefinedColorSpace,
    tone_mapping_mode: ToneMappingMode,
};

// Options to @ref wgpuSurfaceConfigure for defining how a @ref WGPUSurface will be rendered to and presented to the user.
// See @ref Surface-Configuration for more details.
pub const SurfaceConfiguration = extern struct {
    next_in_chain: ?*const ChainedStruct,
    // The @ref WGPUDevice to use to render to surface's textures.
    device: Device,
    // The @ref WGPUTextureFormat of the surface's textures.
    format: TextureFormat,
    // The @ref WGPUTextureUsage of the surface's textures.
    usage: TextureUsage,
    // The width of the surface's textures.
    width: u32,
    // The height of the surface's textures.
    height: u32,
    // The additional @ref WGPUTextureFormat for @ref WGPUTextureView format reinterpretation of the surface's textures.
    view_format_count: usize,
    view_formats: ?[*]const TextureFormat,
    // How the surface's frames will be composited on the screen.
    //
    // If set to @ref WGPUCompositeAlphaMode_Auto,
    // [defaults] to @ref WGPUCompositeAlphaMode_Inherit in native (allowing the mode
    // to be configured externally), and to @ref WGPUCompositeAlphaMode_Opaque in Wasm.
    alpha_mode: CompositeAlphaMode,
    // When and in which order the surface's frames will be shown on the screen.
    //
    // If set to @ref WGPUPresentMode_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUPresentMode_Fifo.
    present_mode: PresentMode,
};

// The root descriptor for the creation of an @ref WGPUSurface with @ref wgpuInstanceCreateSurface.
// It isn't sufficient by itself and must have one of the `WGPUSurfaceSource*` in its chain.
// See @ref Surface-Creation for more details.
pub const SurfaceDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct,
    // Label used to refer to the object.
    label: StringView,
};

// Chained in @ref WGPUSurfaceDescriptor to make an @ref WGPUSurface wrapping an Android [`ANativeWindow`](https://developer.android.com/ndk/reference/group/a-native-window).
pub const SurfaceSourceAndroidNativeWindow = extern struct {
    chain: ChainedStruct,
    // The pointer to the [`ANativeWindow`](https://developer.android.com/ndk/reference/group/a-native-window) that will be wrapped by the @ref WGPUSurface.
    window: *anyopaque,
};

// Chained in @ref WGPUSurfaceDescriptor to make an @ref WGPUSurface wrapping a [`CAMetalLayer`](https://developer.apple.com/documentation/quartzcore/cametallayer?language=objc).
pub const SurfaceSourceMetalLayer = extern struct {
    chain: ChainedStruct,
    // The pointer to the [`CAMetalLayer`](https://developer.apple.com/documentation/quartzcore/cametallayer?language=objc) that will be wrapped by the @ref WGPUSurface.
    layer: *anyopaque,
};

// Chained in @ref WGPUSurfaceDescriptor to make an @ref WGPUSurface wrapping a [Wayland](https://wayland.freedesktop.org/) [`wl_surface`](https://wayland.freedesktop.org/docs/html/apa.html#protocol-spec-wl_surface).
pub const SurfaceSourceWaylandSurface = extern struct {
    chain: ChainedStruct,
    // A [`wl_display`](https://wayland.freedesktop.org/docs/html/apa.html#protocol-spec-wl_display) for this Wayland instance.
    display: *anyopaque,
    // A [`wl_surface`](https://wayland.freedesktop.org/docs/html/apa.html#protocol-spec-wl_surface) that will be wrapped by the @ref WGPUSurface
    surface: *anyopaque,
};

// Chained in @ref WGPUSurfaceDescriptor to make an @ref WGPUSurface wrapping a Windows [`HWND`](https://learn.microsoft.com/en-us/windows/apps/develop/ui-input/retrieve-hwnd).
pub const SurfaceSourceWindowsHWND = extern struct {
    chain: ChainedStruct,
    // The [`HINSTANCE`](https://learn.microsoft.com/en-us/windows/win32/learnwin32/winmain--the-application-entry-point) for this application.
    // Most commonly `GetModuleHandle(nullptr)`.
    hinstance: *anyopaque,
    // The [`HWND`](https://learn.microsoft.com/en-us/windows/apps/develop/ui-input/retrieve-hwnd) that will be wrapped by the @ref WGPUSurface.
    hwnd: *anyopaque,
};

// Chained in @ref WGPUSurfaceDescriptor to make an @ref WGPUSurface wrapping an [XCB](https://xcb.freedesktop.org/) `xcb_window_t`.
pub const SurfaceSourceXCBWindow = extern struct {
    chain: ChainedStruct,
    // The `xcb_connection_t` for the connection to the X server.
    connection: *anyopaque,
    // The `xcb_window_t` for the window that will be wrapped by the @ref WGPUSurface.
    window: u32,
};

// Chained in @ref WGPUSurfaceDescriptor to make an @ref WGPUSurface wrapping an [Xlib](https://www.x.org/releases/current/doc/libX11/libX11/libX11.html) `Window`.
pub const SurfaceSourceXlibWindow = extern struct {
    chain: ChainedStruct,
    // A pointer to the [`Display`](https://www.x.org/releases/current/doc/libX11/libX11/libX11.html#Opening_the_Display) connected to the X server.
    display: *anyopaque,
    // The [`Window`](https://www.x.org/releases/current/doc/libX11/libX11/libX11.html#Creating_Windows) that will be wrapped by the @ref WGPUSurface.
    window: u64,
};

// Queried each frame from a @ref WGPUSurface to get a @ref WGPUTexture to render to along with some metadata.
// See @ref Surface-Presenting for more details.
pub const SurfaceTexture = extern struct {
    next_in_chain: ?*const ChainedStruct,
    // The @ref WGPUTexture representing the frame that will be shown on the surface.
    // It is @ref ReturnedWithOwnership from @ref wgpuSurfaceGetCurrentTexture.
    texture: Texture,
    // Whether the call to @ref wgpuSurfaceGetCurrentTexture succeeded and a hint as to why it might not have.
    status: SurfaceGetCurrentTextureStatus,
};

pub const TexelCopyBufferInfo = extern struct {
    layout: TexelCopyBufferLayout,
    buffer: Buffer,
};

pub const TexelCopyBufferLayout = extern struct {
    offset: u64,
    bytes_per_row: u32,
    rows_per_image: u32,
};

pub const TexelCopyTextureInfo = extern struct {
    texture: Texture,
    mip_level: u32,
    origin: Origin3D,
    // If set to @ref WGPUTextureAspect_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUTextureAspect_All.
    aspect: TextureAspect,
};

pub const TextureBindingLayout = extern struct {
    next_in_chain: ?*const ChainedStruct,
    // If set to @ref WGPUTextureSampleType_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUTextureSampleType_Float.
    sample_type: TextureSampleType,
    // If set to @ref WGPUTextureViewDimension_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUTextureViewDimension_2D.
    view_dimension: TextureViewDimension,
    multisampled: Bool,
};

// Note: While Compatibility Mode is optional to implement, this extension struct
// is required to be accepted (but per the WebGPU spec, its contents are ignored
// on devices that have the @ref WGPUFeatureName_CoreFeaturesAndLimits feature).
pub const TextureBindingViewDimension = extern struct {
    chain: ChainedStruct,
    texture_binding_view_dimension: TextureViewDimension,
};

// When accessed by a shader, the red/green/blue/alpha channels are replaced
// by the value corresponding to the component specified in r, g, b, and a,
// respectively unlike the JS API which uses a string of length four, with
// each character mapping to the texture view's red/green/blue/alpha channels.
pub const TextureComponentSwizzle = extern struct {
    // The value that replaces the red channel in the shader.
    //
    // If set to @ref WGPUComponentSwizzle_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUComponentSwizzle_R.
    r: ComponentSwizzle,
    // The value that replaces the green channel in the shader.
    //
    // If set to @ref WGPUComponentSwizzle_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUComponentSwizzle_G.
    g: ComponentSwizzle,
    // The value that replaces the blue channel in the shader.
    //
    // If set to @ref WGPUComponentSwizzle_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUComponentSwizzle_B.
    b: ComponentSwizzle,
    // The value that replaces the alpha channel in the shader.
    //
    // If set to @ref WGPUComponentSwizzle_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUComponentSwizzle_A.
    a: ComponentSwizzle,
};

pub const TextureComponentSwizzleDescriptor = extern struct {
    chain: ChainedStruct,
    swizzle: TextureComponentSwizzle,
};

pub const TextureDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct,
    label: StringView,
    usage: TextureUsage,
    // If set to @ref WGPUTextureDimension_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUTextureDimension_2D.
    dimension: TextureDimension,
    size: Extent3D,
    format: TextureFormat,
    mip_level_count: u32,
    sample_count: u32,
    view_format_count: usize,
    view_formats: ?[*]const TextureFormat,
};

pub const TextureViewDescriptor = extern struct {
    next_in_chain: ?*const ChainedStruct,
    label: StringView,
    format: TextureFormat,
    dimension: TextureViewDimension,
    base_mip_level: u32,
    mip_level_count: u32,
    base_array_layer: u32,
    array_layer_count: u32,
    // If set to @ref WGPUTextureAspect_Undefined,
    // [defaults](@ref SentinelValues) to @ref WGPUTextureAspect_All.
    aspect: TextureAspect,
    usage: TextureUsage,
};

pub const VertexAttribute = extern struct {
    next_in_chain: ?*const ChainedStruct,
    format: VertexFormat,
    offset: u64,
    shader_location: u32,
};

// If `attributes` is empty *and* `stepMode` is @ref WGPUVertexStepMode_Undefined,
// indicates a "hole" in the parent @ref WGPUVertexState `buffers` array,
// with behavior equivalent to `null` in the JS API.
//
// If `attributes` is empty but `stepMode` is *not* @ref WGPUVertexStepMode_Undefined,
// indicates a vertex buffer with no attributes, with behavior equivalent to
// `{ attributes: [] }` in the JS API. (TODO: If the JS API changes not to
// distinguish these cases, then this distinction doesn't matter and we can
// remove this documentation.)
//
// If `stepMode` is @ref WGPUVertexStepMode_Undefined but `attributes` is *not* empty,
// `stepMode` [defaults](@ref SentinelValues) to @ref WGPUVertexStepMode_Vertex.
pub const VertexBufferLayout = extern struct {
    next_in_chain: ?*const ChainedStruct,
    step_mode: VertexStepMode,
    array_stride: u64,
    attribute_count: usize,
    attributes: ?[*]const VertexAttribute,
};

pub const VertexState = extern struct {
    next_in_chain: ?*const ChainedStruct,
    module: ShaderModule,
    entry_point: StringView,
    constant_count: usize,
    constants: ?[*]const ConstantEntry,
    buffer_count: usize,
    buffers: ?[*]const VertexBufferLayout,
};

// Create a WGPUInstance
pub extern fn wgpuCreateInstance(descriptor: ?*const InstanceDescriptor) Instance;
// Get the list of @ref WGPUInstanceFeatureName values supported by the instance.
pub extern fn wgpuGetInstanceFeatures(features: *SupportedInstanceFeatures) void;
// Get the limits supported by the instance.
pub extern fn wgpuGetInstanceLimits(limits: *InstanceLimits) Status;
// Check whether a particular @ref WGPUInstanceFeatureName is supported by the instance.
pub extern fn wgpuHasInstanceFeature(feature: InstanceFeatureName) Bool;

pub extern fn wgpuAdapterInfoFreeMembers(adapter_info: AdapterInfo) void;
pub extern fn wgpuSupportedFeaturesFreeMembers(supported_features: SupportedFeatures) void;
pub extern fn wgpuSupportedInstanceFeaturesFreeMembers(supported_instance_features: SupportedInstanceFeatures) void;
pub extern fn wgpuSupportedWGSLLanguageFeaturesFreeMembers(supported_wgsl_language_features: SupportedWGSLLanguageFeatures) void;
// Filled by @ref wgpuSurfaceGetCapabilities with what's supported for @ref wgpuSurfaceConfigure for a pair of @ref WGPUSurface and @ref WGPUAdapter.
pub extern fn wgpuSurfaceCapabilitiesFreeMembers(surface_capabilities: SurfaceCapabilities) void;

pub const Adapter = *opaque {
    pub const Self = @This();

    extern fn wgpuAdapterGetLimits(adapter: Adapter, limits: *Limits) Status;
    pub inline fn getLimits(self: Self, limits: *Limits) Status {
        return wgpuAdapterGetLimits(self, limits);
    }

    extern fn wgpuAdapterHasFeature(adapter: Adapter, feature: FeatureName) Bool;
    pub inline fn hasFeature(self: Self, feature: FeatureName) Bool {
        return wgpuAdapterHasFeature(self, feature);
    }

    extern fn wgpuAdapterGetFeatures(adapter: Adapter, features: *SupportedFeatures) void;
    // Get the list of @ref WGPUFeatureName values supported by the adapter.
    pub inline fn getFeatures(self: Self, features: *SupportedFeatures) void {
        return wgpuAdapterGetFeatures(self, features);
    }

    extern fn wgpuAdapterGetInfo(adapter: Adapter, info: *AdapterInfo) Status;
    pub inline fn getInfo(self: Self, info: *AdapterInfo) Status {
        return wgpuAdapterGetInfo(self, info);
    }

    extern fn wgpuAdapterRequestDevice(adapter: Adapter, descriptor: ?*const DeviceDescriptor, callback_info: RequestDeviceCallbackInfo) Future;
    pub inline fn requestDevice(self: Self, descriptor: ?*const DeviceDescriptor, callback_info: RequestDeviceCallbackInfo) Future {
        return wgpuAdapterRequestDevice(self, descriptor, callback_info);
    }

    extern fn wgpuAdapterAddRef(adapter: Adapter) void;
    pub inline fn addRef(self: Self) void {
        return wgpuAdapterAddRef(self);
    }

    extern fn wgpuAdapterRelease(adapter: Adapter) void;
    pub inline fn release(self: Self) void {
        return wgpuAdapterRelease(self);
    }
};

pub const BindGroup = *opaque {
    pub const Self = @This();

    extern fn wgpuBindGroupSetLabel(bind_group: BindGroup, label: StringView) void;
    pub inline fn setLabel(self: Self, label: StringView) void {
        return wgpuBindGroupSetLabel(self, label);
    }

    extern fn wgpuBindGroupAddRef(bind_group: BindGroup) void;
    pub inline fn addRef(self: Self) void {
        return wgpuBindGroupAddRef(self);
    }

    extern fn wgpuBindGroupRelease(bind_group: BindGroup) void;
    pub inline fn release(self: Self) void {
        return wgpuBindGroupRelease(self);
    }
};

pub const BindGroupLayout = *opaque {
    pub const Self = @This();

    extern fn wgpuBindGroupLayoutSetLabel(bind_group_layout: BindGroupLayout, label: StringView) void;
    pub inline fn setLabel(self: Self, label: StringView) void {
        return wgpuBindGroupLayoutSetLabel(self, label);
    }

    extern fn wgpuBindGroupLayoutAddRef(bind_group_layout: BindGroupLayout) void;
    pub inline fn addRef(self: Self) void {
        return wgpuBindGroupLayoutAddRef(self);
    }

    extern fn wgpuBindGroupLayoutRelease(bind_group_layout: BindGroupLayout) void;
    pub inline fn release(self: Self) void {
        return wgpuBindGroupLayoutRelease(self);
    }
};

pub const Buffer = *opaque {
    pub const Self = @This();

    extern fn wgpuBufferMapAsync(buffer: Buffer, mode: MapMode, offset: usize, size: usize, callback_info: BufferMapCallbackInfo) Future;
    pub inline fn mapAsync(self: Self, mode: MapMode, offset: usize, size: usize, callback_info: BufferMapCallbackInfo) Future {
        return wgpuBufferMapAsync(self, mode, offset, size, callback_info);
    }

    extern fn wgpuBufferGetMappedRange(buffer: Buffer, offset: usize, size: usize) *anyopaque;
    // Returns a mutable pointer to beginning of the mapped range.
    // See @ref MappedRangeBehavior for error conditions and guarantees.
    // This function is safe to call inside spontaneous callbacks (see @ref CallbackReentrancy).
    //
    // In Wasm, if `memcpy`ing into this range, prefer using @ref wgpuBufferWriteMappedRange
    // instead for better performance.
    pub inline fn getMappedRange(self: Self, offset: usize, size: usize) *anyopaque {
        return wgpuBufferGetMappedRange(self, offset, size);
    }

    extern fn wgpuBufferGetConstMappedRange(buffer: Buffer, offset: usize, size: usize) *const anyopaque;
    // Returns a const pointer to beginning of the mapped range.
    // It must not be written; writing to this range causes undefined behavior.
    // See @ref MappedRangeBehavior for error conditions and guarantees.
    // This function is safe to call inside spontaneous callbacks (see @ref CallbackReentrancy).
    //
    // In Wasm, if `memcpy`ing from this range, prefer using @ref wgpuBufferReadMappedRange
    // instead for better performance.
    pub inline fn getConstMappedRange(self: Self, offset: usize, size: usize) *const anyopaque {
        return wgpuBufferGetConstMappedRange(self, offset, size);
    }

    extern fn wgpuBufferReadMappedRange(buffer: Buffer, offset: usize, data: *anyopaque, size: usize) Status;
    // Copies a range of data from the buffer mapping into the provided destination pointer.
    // See @ref MappedRangeBehavior for error conditions and guarantees.
    // This function is safe to call inside spontaneous callbacks (see @ref CallbackReentrancy).
    //
    // In Wasm, this is more efficient than copying from a mapped range into a `malloc`'d range.
    pub inline fn readMappedRange(self: Self, offset: usize, data: *anyopaque, size: usize) Status {
        return wgpuBufferReadMappedRange(self, offset, data, size);
    }

    extern fn wgpuBufferWriteMappedRange(buffer: Buffer, offset: usize, data: *const anyopaque, size: usize) Status;
    // Copies a range of data from the provided source pointer into the buffer mapping.
    // See @ref MappedRangeBehavior for error conditions and guarantees.
    // This function is safe to call inside spontaneous callbacks (see @ref CallbackReentrancy).
    //
    // In Wasm, this is more efficient than copying from a `malloc`'d range into a mapped range.
    pub inline fn writeMappedRange(self: Self, offset: usize, data: *const anyopaque, size: usize) Status {
        return wgpuBufferWriteMappedRange(self, offset, data, size);
    }

    extern fn wgpuBufferSetLabel(buffer: Buffer, label: StringView) void;
    pub inline fn setLabel(self: Self, label: StringView) void {
        return wgpuBufferSetLabel(self, label);
    }

    extern fn wgpuBufferGetUsage(buffer: Buffer) BufferUsage;
    pub inline fn getUsage(self: Self) BufferUsage {
        return wgpuBufferGetUsage(self);
    }

    extern fn wgpuBufferGetSize(buffer: Buffer) u64;
    pub inline fn getSize(self: Self) u64 {
        return wgpuBufferGetSize(self);
    }

    extern fn wgpuBufferGetMapState(buffer: Buffer) BufferMapState;
    pub inline fn getMapState(self: Self) BufferMapState {
        return wgpuBufferGetMapState(self);
    }

    extern fn wgpuBufferUnmap(buffer: Buffer) void;
    pub inline fn unmap(self: Self) void {
        return wgpuBufferUnmap(self);
    }

    extern fn wgpuBufferDestroy(buffer: Buffer) void;
    pub inline fn destroy(self: Self) void {
        return wgpuBufferDestroy(self);
    }

    extern fn wgpuBufferAddRef(buffer: Buffer) void;
    pub inline fn addRef(self: Self) void {
        return wgpuBufferAddRef(self);
    }

    extern fn wgpuBufferRelease(buffer: Buffer) void;
    pub inline fn release(self: Self) void {
        return wgpuBufferRelease(self);
    }
};

pub const CommandBuffer = *opaque {
    pub const Self = @This();

    extern fn wgpuCommandBufferSetLabel(command_buffer: CommandBuffer, label: StringView) void;
    pub inline fn setLabel(self: Self, label: StringView) void {
        return wgpuCommandBufferSetLabel(self, label);
    }

    extern fn wgpuCommandBufferAddRef(command_buffer: CommandBuffer) void;
    pub inline fn addRef(self: Self) void {
        return wgpuCommandBufferAddRef(self);
    }

    extern fn wgpuCommandBufferRelease(command_buffer: CommandBuffer) void;
    pub inline fn release(self: Self) void {
        return wgpuCommandBufferRelease(self);
    }
};

pub const CommandEncoder = *opaque {
    pub const Self = @This();

    extern fn wgpuCommandEncoderFinish(command_encoder: CommandEncoder, descriptor: ?*const CommandBufferDescriptor) CommandBuffer;
    pub inline fn finish(self: Self, descriptor: ?*const CommandBufferDescriptor) CommandBuffer {
        return wgpuCommandEncoderFinish(self, descriptor);
    }

    extern fn wgpuCommandEncoderBeginComputePass(command_encoder: CommandEncoder, descriptor: ?*const ComputePassDescriptor) ComputePassEncoder;
    pub inline fn beginComputePass(self: Self, descriptor: ?*const ComputePassDescriptor) ComputePassEncoder {
        return wgpuCommandEncoderBeginComputePass(self, descriptor);
    }

    extern fn wgpuCommandEncoderBeginRenderPass(command_encoder: CommandEncoder, descriptor: *const RenderPassDescriptor) RenderPassEncoder;
    pub inline fn beginRenderPass(self: Self, descriptor: *const RenderPassDescriptor) RenderPassEncoder {
        return wgpuCommandEncoderBeginRenderPass(self, descriptor);
    }

    extern fn wgpuCommandEncoderCopyBufferToBuffer(command_encoder: CommandEncoder, source: Buffer, source_offset: u64, destination: Buffer, destination_offset: u64, size: u64) void;
    pub inline fn copyBufferToBuffer(self: Self, source: Buffer, source_offset: u64, destination: Buffer, destination_offset: u64, size: u64) void {
        return wgpuCommandEncoderCopyBufferToBuffer(self, source, source_offset, destination, destination_offset, size);
    }

    extern fn wgpuCommandEncoderCopyBufferToTexture(command_encoder: CommandEncoder, source: *const TexelCopyBufferInfo, destination: *const TexelCopyTextureInfo, copy_size: *const Extent3D) void;
    pub inline fn copyBufferToTexture(self: Self, source: *const TexelCopyBufferInfo, destination: *const TexelCopyTextureInfo, copy_size: *const Extent3D) void {
        return wgpuCommandEncoderCopyBufferToTexture(self, source, destination, copy_size);
    }

    extern fn wgpuCommandEncoderCopyTextureToBuffer(command_encoder: CommandEncoder, source: *const TexelCopyTextureInfo, destination: *const TexelCopyBufferInfo, copy_size: *const Extent3D) void;
    pub inline fn copyTextureToBuffer(self: Self, source: *const TexelCopyTextureInfo, destination: *const TexelCopyBufferInfo, copy_size: *const Extent3D) void {
        return wgpuCommandEncoderCopyTextureToBuffer(self, source, destination, copy_size);
    }

    extern fn wgpuCommandEncoderCopyTextureToTexture(command_encoder: CommandEncoder, source: *const TexelCopyTextureInfo, destination: *const TexelCopyTextureInfo, copy_size: *const Extent3D) void;
    pub inline fn copyTextureToTexture(self: Self, source: *const TexelCopyTextureInfo, destination: *const TexelCopyTextureInfo, copy_size: *const Extent3D) void {
        return wgpuCommandEncoderCopyTextureToTexture(self, source, destination, copy_size);
    }

    extern fn wgpuCommandEncoderClearBuffer(command_encoder: CommandEncoder, buffer: Buffer, offset: u64, size: u64) void;
    pub inline fn clearBuffer(self: Self, buffer: Buffer, offset: u64, size: u64) void {
        return wgpuCommandEncoderClearBuffer(self, buffer, offset, size);
    }

    extern fn wgpuCommandEncoderInsertDebugMarker(command_encoder: CommandEncoder, marker_label: StringView) void;
    pub inline fn insertDebugMarker(self: Self, marker_label: StringView) void {
        return wgpuCommandEncoderInsertDebugMarker(self, marker_label);
    }

    extern fn wgpuCommandEncoderPopDebugGroup(command_encoder: CommandEncoder) void;
    pub inline fn popDebugGroup(self: Self) void {
        return wgpuCommandEncoderPopDebugGroup(self);
    }

    extern fn wgpuCommandEncoderPushDebugGroup(command_encoder: CommandEncoder, group_label: StringView) void;
    pub inline fn pushDebugGroup(self: Self, group_label: StringView) void {
        return wgpuCommandEncoderPushDebugGroup(self, group_label);
    }

    extern fn wgpuCommandEncoderResolveQuerySet(command_encoder: CommandEncoder, query_set: QuerySet, first_query: u32, query_count: u32, destination: Buffer, destination_offset: u64) void;
    pub inline fn resolveQuerySet(self: Self, query_set: QuerySet, first_query: u32, query_count: u32, destination: Buffer, destination_offset: u64) void {
        return wgpuCommandEncoderResolveQuerySet(self, query_set, first_query, query_count, destination, destination_offset);
    }

    extern fn wgpuCommandEncoderWriteTimestamp(command_encoder: CommandEncoder, query_set: QuerySet, query_index: u32) void;
    pub inline fn writeTimestamp(self: Self, query_set: QuerySet, query_index: u32) void {
        return wgpuCommandEncoderWriteTimestamp(self, query_set, query_index);
    }

    extern fn wgpuCommandEncoderSetLabel(command_encoder: CommandEncoder, label: StringView) void;
    pub inline fn setLabel(self: Self, label: StringView) void {
        return wgpuCommandEncoderSetLabel(self, label);
    }

    extern fn wgpuCommandEncoderAddRef(command_encoder: CommandEncoder) void;
    pub inline fn addRef(self: Self) void {
        return wgpuCommandEncoderAddRef(self);
    }

    extern fn wgpuCommandEncoderRelease(command_encoder: CommandEncoder) void;
    pub inline fn release(self: Self) void {
        return wgpuCommandEncoderRelease(self);
    }
};

pub const ComputePassEncoder = *opaque {
    pub const Self = @This();

    extern fn wgpuComputePassEncoderInsertDebugMarker(compute_pass_encoder: ComputePassEncoder, marker_label: StringView) void;
    pub inline fn insertDebugMarker(self: Self, marker_label: StringView) void {
        return wgpuComputePassEncoderInsertDebugMarker(self, marker_label);
    }

    extern fn wgpuComputePassEncoderPopDebugGroup(compute_pass_encoder: ComputePassEncoder) void;
    pub inline fn popDebugGroup(self: Self) void {
        return wgpuComputePassEncoderPopDebugGroup(self);
    }

    extern fn wgpuComputePassEncoderPushDebugGroup(compute_pass_encoder: ComputePassEncoder, group_label: StringView) void;
    pub inline fn pushDebugGroup(self: Self, group_label: StringView) void {
        return wgpuComputePassEncoderPushDebugGroup(self, group_label);
    }

    extern fn wgpuComputePassEncoderSetPipeline(compute_pass_encoder: ComputePassEncoder, pipeline: ComputePipeline) void;
    pub inline fn setPipeline(self: Self, pipeline: ComputePipeline) void {
        return wgpuComputePassEncoderSetPipeline(self, pipeline);
    }

    extern fn wgpuComputePassEncoderSetBindGroup(compute_pass_encoder: ComputePassEncoder, group_index: u32, group: ?BindGroup, dynamic_offset_count: usize, dynamic_offsets: ?*const u32) void;
    pub inline fn setBindGroup(self: Self, group_index: u32, group: ?BindGroup, dynamic_offset_count: usize, dynamic_offsets: ?[*]const u32) void {
        return wgpuComputePassEncoderSetBindGroup(self, group_index, group, dynamic_offset_count, dynamic_offsets);
    }

    extern fn wgpuComputePassEncoderSetImmediates(compute_pass_encoder: ComputePassEncoder, offset: u32, data: *const anyopaque, size: usize) void;
    pub inline fn setImmediates(self: Self, offset: u32, data: *const anyopaque, size: usize) void {
        return wgpuComputePassEncoderSetImmediates(self, offset, data, size);
    }

    extern fn wgpuComputePassEncoderDispatchWorkgroups(compute_pass_encoder: ComputePassEncoder, workgroup_count_x: u32, workgroup_count_y: u32, workgroup_count_z: u32) void;
    pub inline fn dispatchWorkgroups(self: Self, workgroup_count_x: u32, workgroup_count_y: u32, workgroup_count_z: u32) void {
        return wgpuComputePassEncoderDispatchWorkgroups(self, workgroup_count_x, workgroup_count_y, workgroup_count_z);
    }

    extern fn wgpuComputePassEncoderDispatchWorkgroupsIndirect(compute_pass_encoder: ComputePassEncoder, indirect_buffer: Buffer, indirect_offset: u64) void;
    pub inline fn dispatchWorkgroupsIndirect(self: Self, indirect_buffer: Buffer, indirect_offset: u64) void {
        return wgpuComputePassEncoderDispatchWorkgroupsIndirect(self, indirect_buffer, indirect_offset);
    }

    extern fn wgpuComputePassEncoderEnd(compute_pass_encoder: ComputePassEncoder) void;
    pub inline fn end(self: Self) void {
        return wgpuComputePassEncoderEnd(self);
    }

    extern fn wgpuComputePassEncoderSetLabel(compute_pass_encoder: ComputePassEncoder, label: StringView) void;
    pub inline fn setLabel(self: Self, label: StringView) void {
        return wgpuComputePassEncoderSetLabel(self, label);
    }

    extern fn wgpuComputePassEncoderAddRef(compute_pass_encoder: ComputePassEncoder) void;
    pub inline fn addRef(self: Self) void {
        return wgpuComputePassEncoderAddRef(self);
    }

    extern fn wgpuComputePassEncoderRelease(compute_pass_encoder: ComputePassEncoder) void;
    pub inline fn release(self: Self) void {
        return wgpuComputePassEncoderRelease(self);
    }
};

pub const ComputePipeline = *opaque {
    pub const Self = @This();

    extern fn wgpuComputePipelineGetBindGroupLayout(compute_pipeline: ComputePipeline, group_index: u32) BindGroupLayout;
    pub inline fn getBindGroupLayout(self: Self, group_index: u32) BindGroupLayout {
        return wgpuComputePipelineGetBindGroupLayout(self, group_index);
    }

    extern fn wgpuComputePipelineSetLabel(compute_pipeline: ComputePipeline, label: StringView) void;
    pub inline fn setLabel(self: Self, label: StringView) void {
        return wgpuComputePipelineSetLabel(self, label);
    }

    extern fn wgpuComputePipelineAddRef(compute_pipeline: ComputePipeline) void;
    pub inline fn addRef(self: Self) void {
        return wgpuComputePipelineAddRef(self);
    }

    extern fn wgpuComputePipelineRelease(compute_pipeline: ComputePipeline) void;
    pub inline fn release(self: Self) void {
        return wgpuComputePipelineRelease(self);
    }
};

// TODO
//
// Releasing the last ref to a `WGPUDevice` also calls @ref wgpuDeviceDestroy.
// For more info, see @ref DeviceRelease.
pub const Device = *opaque {
    pub const Self = @This();

    extern fn wgpuDeviceCreateBindGroup(device: Device, descriptor: *const BindGroupDescriptor) BindGroup;
    pub inline fn createBindGroup(self: Self, descriptor: *const BindGroupDescriptor) BindGroup {
        return wgpuDeviceCreateBindGroup(self, descriptor);
    }

    extern fn wgpuDeviceCreateBindGroupLayout(device: Device, descriptor: *const BindGroupLayoutDescriptor) BindGroupLayout;
    pub inline fn createBindGroupLayout(self: Self, descriptor: *const BindGroupLayoutDescriptor) BindGroupLayout {
        return wgpuDeviceCreateBindGroupLayout(self, descriptor);
    }

    extern fn wgpuDeviceCreateBuffer(device: Device, descriptor: *const BufferDescriptor) ?Buffer;
    // TODO
    //
    // If @ref WGPUBufferDescriptor::mappedAtCreation is `true` and the mapping allocation fails,
    // returns `NULL`.
    pub inline fn createBuffer(self: Self, descriptor: *const BufferDescriptor) ?Buffer {
        return wgpuDeviceCreateBuffer(self, descriptor);
    }

    extern fn wgpuDeviceCreateCommandEncoder(device: Device, descriptor: ?*const CommandEncoderDescriptor) CommandEncoder;
    pub inline fn createCommandEncoder(self: Self, descriptor: ?*const CommandEncoderDescriptor) CommandEncoder {
        return wgpuDeviceCreateCommandEncoder(self, descriptor);
    }

    extern fn wgpuDeviceCreateComputePipeline(device: Device, descriptor: *const ComputePipelineDescriptor) ComputePipeline;
    pub inline fn createComputePipeline(self: Self, descriptor: *const ComputePipelineDescriptor) ComputePipeline {
        return wgpuDeviceCreateComputePipeline(self, descriptor);
    }

    extern fn wgpuDeviceCreateComputePipelineAsync(device: Device, descriptor: *const ComputePipelineDescriptor, callback_info: CreateComputePipelineAsyncCallbackInfo) Future;
    pub inline fn createComputePipelineAsync(self: Self, descriptor: *const ComputePipelineDescriptor, callback_info: CreateComputePipelineAsyncCallbackInfo) Future {
        return wgpuDeviceCreateComputePipelineAsync(self, descriptor, callback_info);
    }

    extern fn wgpuDeviceCreatePipelineLayout(device: Device, descriptor: *const PipelineLayoutDescriptor) PipelineLayout;
    pub inline fn createPipelineLayout(self: Self, descriptor: *const PipelineLayoutDescriptor) PipelineLayout {
        return wgpuDeviceCreatePipelineLayout(self, descriptor);
    }

    extern fn wgpuDeviceCreateQuerySet(device: Device, descriptor: *const QuerySetDescriptor) QuerySet;
    pub inline fn createQuerySet(self: Self, descriptor: *const QuerySetDescriptor) QuerySet {
        return wgpuDeviceCreateQuerySet(self, descriptor);
    }

    extern fn wgpuDeviceCreateRenderPipelineAsync(device: Device, descriptor: *const RenderPipelineDescriptor, callback_info: CreateRenderPipelineAsyncCallbackInfo) Future;
    pub inline fn createRenderPipelineAsync(self: Self, descriptor: *const RenderPipelineDescriptor, callback_info: CreateRenderPipelineAsyncCallbackInfo) Future {
        return wgpuDeviceCreateRenderPipelineAsync(self, descriptor, callback_info);
    }

    extern fn wgpuDeviceCreateRenderBundleEncoder(device: Device, descriptor: *const RenderBundleEncoderDescriptor) RenderBundleEncoder;
    pub inline fn createRenderBundleEncoder(self: Self, descriptor: *const RenderBundleEncoderDescriptor) RenderBundleEncoder {
        return wgpuDeviceCreateRenderBundleEncoder(self, descriptor);
    }

    extern fn wgpuDeviceCreateRenderPipeline(device: Device, descriptor: *const RenderPipelineDescriptor) RenderPipeline;
    pub inline fn createRenderPipeline(self: Self, descriptor: *const RenderPipelineDescriptor) RenderPipeline {
        return wgpuDeviceCreateRenderPipeline(self, descriptor);
    }

    extern fn wgpuDeviceCreateSampler(device: Device, descriptor: ?*const SamplerDescriptor) Sampler;
    pub inline fn createSampler(self: Self, descriptor: ?*const SamplerDescriptor) Sampler {
        return wgpuDeviceCreateSampler(self, descriptor);
    }

    extern fn wgpuDeviceCreateShaderModule(device: Device, descriptor: *const ShaderModuleDescriptor) ShaderModule;
    pub inline fn createShaderModule(self: Self, descriptor: *const ShaderModuleDescriptor) ShaderModule {
        return wgpuDeviceCreateShaderModule(self, descriptor);
    }

    extern fn wgpuDeviceCreateTexture(device: Device, descriptor: *const TextureDescriptor) Texture;
    pub inline fn createTexture(self: Self, descriptor: *const TextureDescriptor) Texture {
        return wgpuDeviceCreateTexture(self, descriptor);
    }

    extern fn wgpuDeviceDestroy(device: Device) void;
    pub inline fn destroy(self: Self) void {
        return wgpuDeviceDestroy(self);
    }

    extern fn wgpuDeviceGetLostFuture(device: Device) Future;
    pub inline fn getLostFuture(self: Self) Future {
        return wgpuDeviceGetLostFuture(self);
    }

    extern fn wgpuDeviceGetLimits(device: Device, limits: *Limits) Status;
    pub inline fn getLimits(self: Self, limits: *Limits) Status {
        return wgpuDeviceGetLimits(self, limits);
    }

    extern fn wgpuDeviceHasFeature(device: Device, feature: FeatureName) Bool;
    pub inline fn hasFeature(self: Self, feature: FeatureName) Bool {
        return wgpuDeviceHasFeature(self, feature);
    }

    extern fn wgpuDeviceGetFeatures(device: Device, features: *SupportedFeatures) void;
    // Get the list of @ref WGPUFeatureName values supported by the device.
    pub inline fn getFeatures(self: Self, features: *SupportedFeatures) void {
        return wgpuDeviceGetFeatures(self, features);
    }

    extern fn wgpuDeviceGetAdapterInfo(device: Device, adapter_info: *AdapterInfo) Status;
    pub inline fn getAdapterInfo(self: Self, adapter_info: *AdapterInfo) Status {
        return wgpuDeviceGetAdapterInfo(self, adapter_info);
    }

    extern fn wgpuDeviceGetQueue(device: Device) Queue;
    pub inline fn getQueue(self: Self) Queue {
        return wgpuDeviceGetQueue(self);
    }

    extern fn wgpuDevicePushErrorScope(device: Device, filter: ErrorFilter) void;
    // Pushes an error scope to the current thread's error scope stack.
    // See @ref ErrorScopes.
    pub inline fn pushErrorScope(self: Self, filter: ErrorFilter) void {
        return wgpuDevicePushErrorScope(self, filter);
    }

    extern fn wgpuDevicePopErrorScope(device: Device, callback_info: PopErrorScopeCallbackInfo) Future;
    // Pops an error scope to the current thread's error scope stack,
    // asynchronously returning the result. See @ref ErrorScopes.
    pub inline fn popErrorScope(self: Self, callback_info: PopErrorScopeCallbackInfo) Future {
        return wgpuDevicePopErrorScope(self, callback_info);
    }

    extern fn wgpuDeviceSetLabel(device: Device, label: StringView) void;
    pub inline fn setLabel(self: Self, label: StringView) void {
        return wgpuDeviceSetLabel(self, label);
    }

    extern fn wgpuDeviceAddRef(device: Device) void;
    pub inline fn addRef(self: Self) void {
        return wgpuDeviceAddRef(self);
    }

    extern fn wgpuDeviceRelease(device: Device) void;
    pub inline fn release(self: Self) void {
        return wgpuDeviceRelease(self);
    }
};

// A sampleable 2D texture that may perform 0-copy YUV sampling internally. Creation of @ref WGPUExternalTexture is extremely implementation-dependent and not defined in this header.
pub const ExternalTexture = *opaque {
    pub const Self = @This();

    extern fn wgpuExternalTextureSetLabel(external_texture: ExternalTexture, label: StringView) void;
    pub inline fn setLabel(self: Self, label: StringView) void {
        return wgpuExternalTextureSetLabel(self, label);
    }

    extern fn wgpuExternalTextureAddRef(external_texture: ExternalTexture) void;
    pub inline fn addRef(self: Self) void {
        return wgpuExternalTextureAddRef(self);
    }

    extern fn wgpuExternalTextureRelease(external_texture: ExternalTexture) void;
    pub inline fn release(self: Self) void {
        return wgpuExternalTextureRelease(self);
    }
};

pub const Instance = *opaque {
    pub const Self = @This();

    extern fn wgpuInstanceCreateSurface(instance: Instance, descriptor: *const SurfaceDescriptor) Surface;
    // Creates a @ref WGPUSurface, see @ref Surface-Creation for more details.
    pub inline fn createSurface(self: Self, descriptor: *const SurfaceDescriptor) Surface {
        return wgpuInstanceCreateSurface(self, descriptor);
    }

    extern fn wgpuInstanceGetWGSLLanguageFeatures(instance: Instance, features: *SupportedWGSLLanguageFeatures) void;
    // Get the list of @ref WGPUWGSLLanguageFeatureName values supported by the instance.
    pub inline fn getWGSLLanguageFeatures(self: Self, features: *SupportedWGSLLanguageFeatures) void {
        return wgpuInstanceGetWGSLLanguageFeatures(self, features);
    }

    extern fn wgpuInstanceHasWGSLLanguageFeature(instance: Instance, feature: WGSLLanguageFeatureName) Bool;
    pub inline fn hasWGSLLanguageFeature(self: Self, feature: WGSLLanguageFeatureName) Bool {
        return wgpuInstanceHasWGSLLanguageFeature(self, feature);
    }

    extern fn wgpuInstanceProcessEvents(instance: Instance) void;
    // Processes asynchronous events on this `WGPUInstance`, calling any callbacks for asynchronous operations created with @ref WGPUCallbackMode_AllowProcessEvents.
    //
    // See @ref Process-Events for more information.
    pub inline fn processEvents(self: Self) void {
        return wgpuInstanceProcessEvents(self);
    }

    extern fn wgpuInstanceRequestAdapter(instance: Instance, options: ?*const RequestAdapterOptions, callback_info: RequestAdapterCallbackInfo) Future;
    pub inline fn requestAdapter(self: Self, options: ?*const RequestAdapterOptions, callback_info: RequestAdapterCallbackInfo) Future {
        return wgpuInstanceRequestAdapter(self, options, callback_info);
    }

    extern fn wgpuInstanceWaitAny(instance: Instance, future_count: usize, futures: ?*FutureWaitInfo, timeout_ns: u64) WaitStatus;
    // Wait for at least one WGPUFuture in `futures` to complete, and call callbacks of the respective completed asynchronous operations.
    //
    // See @ref Wait-Any for more information.
    pub inline fn waitAny(self: Self, future_count: usize, futures: ?*FutureWaitInfo, timeout_ns: u64) WaitStatus {
        return wgpuInstanceWaitAny(self, future_count, futures, timeout_ns);
    }

    extern fn wgpuInstanceAddRef(instance: Instance) void;
    pub inline fn addRef(self: Self) void {
        return wgpuInstanceAddRef(self);
    }

    extern fn wgpuInstanceRelease(instance: Instance) void;
    pub inline fn release(self: Self) void {
        return wgpuInstanceRelease(self);
    }
};

pub const PipelineLayout = *opaque {
    pub const Self = @This();

    extern fn wgpuPipelineLayoutSetLabel(pipeline_layout: PipelineLayout, label: StringView) void;
    pub inline fn setLabel(self: Self, label: StringView) void {
        return wgpuPipelineLayoutSetLabel(self, label);
    }

    extern fn wgpuPipelineLayoutAddRef(pipeline_layout: PipelineLayout) void;
    pub inline fn addRef(self: Self) void {
        return wgpuPipelineLayoutAddRef(self);
    }

    extern fn wgpuPipelineLayoutRelease(pipeline_layout: PipelineLayout) void;
    pub inline fn release(self: Self) void {
        return wgpuPipelineLayoutRelease(self);
    }
};

pub const QuerySet = *opaque {
    pub const Self = @This();

    extern fn wgpuQuerySetSetLabel(query_set: QuerySet, label: StringView) void;
    pub inline fn setLabel(self: Self, label: StringView) void {
        return wgpuQuerySetSetLabel(self, label);
    }

    extern fn wgpuQuerySetGetType(query_set: QuerySet) QueryType;
    pub inline fn getType(self: Self) QueryType {
        return wgpuQuerySetGetType(self);
    }

    extern fn wgpuQuerySetGetCount(query_set: QuerySet) u32;
    pub inline fn getCount(self: Self) u32 {
        return wgpuQuerySetGetCount(self);
    }

    extern fn wgpuQuerySetDestroy(query_set: QuerySet) void;
    pub inline fn destroy(self: Self) void {
        return wgpuQuerySetDestroy(self);
    }

    extern fn wgpuQuerySetAddRef(query_set: QuerySet) void;
    pub inline fn addRef(self: Self) void {
        return wgpuQuerySetAddRef(self);
    }

    extern fn wgpuQuerySetRelease(query_set: QuerySet) void;
    pub inline fn release(self: Self) void {
        return wgpuQuerySetRelease(self);
    }
};

pub const Queue = *opaque {
    pub const Self = @This();

    extern fn wgpuQueueSubmit(queue: Queue, command_count: usize, commands: ?*const CommandBuffer) void;
    pub inline fn submit(self: Self, command_count: usize, commands: ?[*]const CommandBuffer) void {
        return wgpuQueueSubmit(self, command_count, commands);
    }

    extern fn wgpuQueueOnSubmittedWorkDone(queue: Queue, callback_info: QueueWorkDoneCallbackInfo) Future;
    pub inline fn onSubmittedWorkDone(self: Self, callback_info: QueueWorkDoneCallbackInfo) Future {
        return wgpuQueueOnSubmittedWorkDone(self, callback_info);
    }

    extern fn wgpuQueueWriteBuffer(queue: Queue, buffer: Buffer, buffer_offset: u64, data: *const anyopaque, size: usize) void;
    // Produces a @ref DeviceError both content-timeline (`size` alignment) and device-timeline
    // errors defined by the WebGPU specification.
    pub inline fn writeBuffer(self: Self, buffer: Buffer, buffer_offset: u64, data: *const anyopaque, size: usize) void {
        return wgpuQueueWriteBuffer(self, buffer, buffer_offset, data, size);
    }

    extern fn wgpuQueueWriteTexture(queue: Queue, destination: *const TexelCopyTextureInfo, data: *const anyopaque, data_size: usize, data_layout: *const TexelCopyBufferLayout, write_size: *const Extent3D) void;
    pub inline fn writeTexture(self: Self, destination: *const TexelCopyTextureInfo, data: *const anyopaque, data_size: usize, data_layout: *const TexelCopyBufferLayout, write_size: *const Extent3D) void {
        return wgpuQueueWriteTexture(self, destination, data, data_size, data_layout, write_size);
    }

    extern fn wgpuQueueSetLabel(queue: Queue, label: StringView) void;
    pub inline fn setLabel(self: Self, label: StringView) void {
        return wgpuQueueSetLabel(self, label);
    }

    extern fn wgpuQueueAddRef(queue: Queue) void;
    pub inline fn addRef(self: Self) void {
        return wgpuQueueAddRef(self);
    }

    extern fn wgpuQueueRelease(queue: Queue) void;
    pub inline fn release(self: Self) void {
        return wgpuQueueRelease(self);
    }
};

pub const RenderBundle = *opaque {
    pub const Self = @This();

    extern fn wgpuRenderBundleSetLabel(render_bundle: RenderBundle, label: StringView) void;
    pub inline fn setLabel(self: Self, label: StringView) void {
        return wgpuRenderBundleSetLabel(self, label);
    }

    extern fn wgpuRenderBundleAddRef(render_bundle: RenderBundle) void;
    pub inline fn addRef(self: Self) void {
        return wgpuRenderBundleAddRef(self);
    }

    extern fn wgpuRenderBundleRelease(render_bundle: RenderBundle) void;
    pub inline fn release(self: Self) void {
        return wgpuRenderBundleRelease(self);
    }
};

pub const RenderBundleEncoder = *opaque {
    pub const Self = @This();

    extern fn wgpuRenderBundleEncoderSetPipeline(render_bundle_encoder: RenderBundleEncoder, pipeline: RenderPipeline) void;
    pub inline fn setPipeline(self: Self, pipeline: RenderPipeline) void {
        return wgpuRenderBundleEncoderSetPipeline(self, pipeline);
    }

    extern fn wgpuRenderBundleEncoderSetBindGroup(render_bundle_encoder: RenderBundleEncoder, group_index: u32, group: ?BindGroup, dynamic_offset_count: usize, dynamic_offsets: ?*const u32) void;
    pub inline fn setBindGroup(self: Self, group_index: u32, group: ?BindGroup, dynamic_offset_count: usize, dynamic_offsets: ?[*]const u32) void {
        return wgpuRenderBundleEncoderSetBindGroup(self, group_index, group, dynamic_offset_count, dynamic_offsets);
    }

    extern fn wgpuRenderBundleEncoderSetImmediates(render_bundle_encoder: RenderBundleEncoder, offset: u32, data: *const anyopaque, size: usize) void;
    pub inline fn setImmediates(self: Self, offset: u32, data: *const anyopaque, size: usize) void {
        return wgpuRenderBundleEncoderSetImmediates(self, offset, data, size);
    }

    extern fn wgpuRenderBundleEncoderDraw(render_bundle_encoder: RenderBundleEncoder, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void;
    pub inline fn draw(self: Self, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void {
        return wgpuRenderBundleEncoderDraw(self, vertex_count, instance_count, first_vertex, first_instance);
    }

    extern fn wgpuRenderBundleEncoderDrawIndexed(render_bundle_encoder: RenderBundleEncoder, index_count: u32, instance_count: u32, first_index: u32, base_vertex: i32, first_instance: u32) void;
    pub inline fn drawIndexed(self: Self, index_count: u32, instance_count: u32, first_index: u32, base_vertex: i32, first_instance: u32) void {
        return wgpuRenderBundleEncoderDrawIndexed(self, index_count, instance_count, first_index, base_vertex, first_instance);
    }

    extern fn wgpuRenderBundleEncoderDrawIndirect(render_bundle_encoder: RenderBundleEncoder, indirect_buffer: Buffer, indirect_offset: u64) void;
    pub inline fn drawIndirect(self: Self, indirect_buffer: Buffer, indirect_offset: u64) void {
        return wgpuRenderBundleEncoderDrawIndirect(self, indirect_buffer, indirect_offset);
    }

    extern fn wgpuRenderBundleEncoderDrawIndexedIndirect(render_bundle_encoder: RenderBundleEncoder, indirect_buffer: Buffer, indirect_offset: u64) void;
    pub inline fn drawIndexedIndirect(self: Self, indirect_buffer: Buffer, indirect_offset: u64) void {
        return wgpuRenderBundleEncoderDrawIndexedIndirect(self, indirect_buffer, indirect_offset);
    }

    extern fn wgpuRenderBundleEncoderInsertDebugMarker(render_bundle_encoder: RenderBundleEncoder, marker_label: StringView) void;
    pub inline fn insertDebugMarker(self: Self, marker_label: StringView) void {
        return wgpuRenderBundleEncoderInsertDebugMarker(self, marker_label);
    }

    extern fn wgpuRenderBundleEncoderPopDebugGroup(render_bundle_encoder: RenderBundleEncoder) void;
    pub inline fn popDebugGroup(self: Self) void {
        return wgpuRenderBundleEncoderPopDebugGroup(self);
    }

    extern fn wgpuRenderBundleEncoderPushDebugGroup(render_bundle_encoder: RenderBundleEncoder, group_label: StringView) void;
    pub inline fn pushDebugGroup(self: Self, group_label: StringView) void {
        return wgpuRenderBundleEncoderPushDebugGroup(self, group_label);
    }

    extern fn wgpuRenderBundleEncoderSetVertexBuffer(render_bundle_encoder: RenderBundleEncoder, slot: u32, buffer: ?Buffer, offset: u64, size: u64) void;
    pub inline fn setVertexBuffer(self: Self, slot: u32, buffer: ?Buffer, offset: u64, size: u64) void {
        return wgpuRenderBundleEncoderSetVertexBuffer(self, slot, buffer, offset, size);
    }

    extern fn wgpuRenderBundleEncoderSetIndexBuffer(render_bundle_encoder: RenderBundleEncoder, buffer: Buffer, format: IndexFormat, offset: u64, size: u64) void;
    pub inline fn setIndexBuffer(self: Self, buffer: Buffer, format: IndexFormat, offset: u64, size: u64) void {
        return wgpuRenderBundleEncoderSetIndexBuffer(self, buffer, format, offset, size);
    }

    extern fn wgpuRenderBundleEncoderFinish(render_bundle_encoder: RenderBundleEncoder, descriptor: ?*const RenderBundleDescriptor) RenderBundle;
    pub inline fn finish(self: Self, descriptor: ?*const RenderBundleDescriptor) RenderBundle {
        return wgpuRenderBundleEncoderFinish(self, descriptor);
    }

    extern fn wgpuRenderBundleEncoderSetLabel(render_bundle_encoder: RenderBundleEncoder, label: StringView) void;
    pub inline fn setLabel(self: Self, label: StringView) void {
        return wgpuRenderBundleEncoderSetLabel(self, label);
    }

    extern fn wgpuRenderBundleEncoderAddRef(render_bundle_encoder: RenderBundleEncoder) void;
    pub inline fn addRef(self: Self) void {
        return wgpuRenderBundleEncoderAddRef(self);
    }

    extern fn wgpuRenderBundleEncoderRelease(render_bundle_encoder: RenderBundleEncoder) void;
    pub inline fn release(self: Self) void {
        return wgpuRenderBundleEncoderRelease(self);
    }
};

pub const RenderPassEncoder = *opaque {
    pub const Self = @This();

    extern fn wgpuRenderPassEncoderSetPipeline(render_pass_encoder: RenderPassEncoder, pipeline: RenderPipeline) void;
    pub inline fn setPipeline(self: Self, pipeline: RenderPipeline) void {
        return wgpuRenderPassEncoderSetPipeline(self, pipeline);
    }

    extern fn wgpuRenderPassEncoderSetBindGroup(render_pass_encoder: RenderPassEncoder, group_index: u32, group: ?BindGroup, dynamic_offset_count: usize, dynamic_offsets: ?*const u32) void;
    pub inline fn setBindGroup(self: Self, group_index: u32, group: ?BindGroup, dynamic_offset_count: usize, dynamic_offsets: ?[*]const u32) void {
        return wgpuRenderPassEncoderSetBindGroup(self, group_index, group, dynamic_offset_count, dynamic_offsets);
    }

    extern fn wgpuRenderPassEncoderSetImmediates(render_pass_encoder: RenderPassEncoder, offset: u32, data: *const anyopaque, size: usize) void;
    pub inline fn setImmediates(self: Self, offset: u32, data: *const anyopaque, size: usize) void {
        return wgpuRenderPassEncoderSetImmediates(self, offset, data, size);
    }

    extern fn wgpuRenderPassEncoderDraw(render_pass_encoder: RenderPassEncoder, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void;
    pub inline fn draw(self: Self, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void {
        return wgpuRenderPassEncoderDraw(self, vertex_count, instance_count, first_vertex, first_instance);
    }

    extern fn wgpuRenderPassEncoderDrawIndexed(render_pass_encoder: RenderPassEncoder, index_count: u32, instance_count: u32, first_index: u32, base_vertex: i32, first_instance: u32) void;
    pub inline fn drawIndexed(self: Self, index_count: u32, instance_count: u32, first_index: u32, base_vertex: i32, first_instance: u32) void {
        return wgpuRenderPassEncoderDrawIndexed(self, index_count, instance_count, first_index, base_vertex, first_instance);
    }

    extern fn wgpuRenderPassEncoderDrawIndirect(render_pass_encoder: RenderPassEncoder, indirect_buffer: Buffer, indirect_offset: u64) void;
    pub inline fn drawIndirect(self: Self, indirect_buffer: Buffer, indirect_offset: u64) void {
        return wgpuRenderPassEncoderDrawIndirect(self, indirect_buffer, indirect_offset);
    }

    extern fn wgpuRenderPassEncoderDrawIndexedIndirect(render_pass_encoder: RenderPassEncoder, indirect_buffer: Buffer, indirect_offset: u64) void;
    pub inline fn drawIndexedIndirect(self: Self, indirect_buffer: Buffer, indirect_offset: u64) void {
        return wgpuRenderPassEncoderDrawIndexedIndirect(self, indirect_buffer, indirect_offset);
    }

    extern fn wgpuRenderPassEncoderExecuteBundles(render_pass_encoder: RenderPassEncoder, bundle_count: usize, bundles: ?*const RenderBundle) void;
    pub inline fn executeBundles(self: Self, bundle_count: usize, bundles: ?[*]const RenderBundle) void {
        return wgpuRenderPassEncoderExecuteBundles(self, bundle_count, bundles);
    }

    extern fn wgpuRenderPassEncoderInsertDebugMarker(render_pass_encoder: RenderPassEncoder, marker_label: StringView) void;
    pub inline fn insertDebugMarker(self: Self, marker_label: StringView) void {
        return wgpuRenderPassEncoderInsertDebugMarker(self, marker_label);
    }

    extern fn wgpuRenderPassEncoderPopDebugGroup(render_pass_encoder: RenderPassEncoder) void;
    pub inline fn popDebugGroup(self: Self) void {
        return wgpuRenderPassEncoderPopDebugGroup(self);
    }

    extern fn wgpuRenderPassEncoderPushDebugGroup(render_pass_encoder: RenderPassEncoder, group_label: StringView) void;
    pub inline fn pushDebugGroup(self: Self, group_label: StringView) void {
        return wgpuRenderPassEncoderPushDebugGroup(self, group_label);
    }

    extern fn wgpuRenderPassEncoderSetStencilReference(render_pass_encoder: RenderPassEncoder, reference: u32) void;
    pub inline fn setStencilReference(self: Self, reference: u32) void {
        return wgpuRenderPassEncoderSetStencilReference(self, reference);
    }

    extern fn wgpuRenderPassEncoderSetBlendConstant(render_pass_encoder: RenderPassEncoder, color: *const Color) void;
    pub inline fn setBlendConstant(self: Self, color: *const Color) void {
        return wgpuRenderPassEncoderSetBlendConstant(self, color);
    }

    extern fn wgpuRenderPassEncoderSetViewport(render_pass_encoder: RenderPassEncoder, x: f32, y: f32, width: f32, height: f32, min_depth: f32, max_depth: f32) void;
    // TODO
    //
    // If any argument is non-finite, produces a @ref NonFiniteFloatValueError.
    pub inline fn setViewport(self: Self, x: f32, y: f32, width: f32, height: f32, min_depth: f32, max_depth: f32) void {
        return wgpuRenderPassEncoderSetViewport(self, x, y, width, height, min_depth, max_depth);
    }

    extern fn wgpuRenderPassEncoderSetScissorRect(render_pass_encoder: RenderPassEncoder, x: u32, y: u32, width: u32, height: u32) void;
    pub inline fn setScissorRect(self: Self, x: u32, y: u32, width: u32, height: u32) void {
        return wgpuRenderPassEncoderSetScissorRect(self, x, y, width, height);
    }

    extern fn wgpuRenderPassEncoderSetVertexBuffer(render_pass_encoder: RenderPassEncoder, slot: u32, buffer: ?Buffer, offset: u64, size: u64) void;
    pub inline fn setVertexBuffer(self: Self, slot: u32, buffer: ?Buffer, offset: u64, size: u64) void {
        return wgpuRenderPassEncoderSetVertexBuffer(self, slot, buffer, offset, size);
    }

    extern fn wgpuRenderPassEncoderSetIndexBuffer(render_pass_encoder: RenderPassEncoder, buffer: Buffer, format: IndexFormat, offset: u64, size: u64) void;
    pub inline fn setIndexBuffer(self: Self, buffer: Buffer, format: IndexFormat, offset: u64, size: u64) void {
        return wgpuRenderPassEncoderSetIndexBuffer(self, buffer, format, offset, size);
    }

    extern fn wgpuRenderPassEncoderBeginOcclusionQuery(render_pass_encoder: RenderPassEncoder, query_index: u32) void;
    pub inline fn beginOcclusionQuery(self: Self, query_index: u32) void {
        return wgpuRenderPassEncoderBeginOcclusionQuery(self, query_index);
    }

    extern fn wgpuRenderPassEncoderEndOcclusionQuery(render_pass_encoder: RenderPassEncoder) void;
    pub inline fn endOcclusionQuery(self: Self) void {
        return wgpuRenderPassEncoderEndOcclusionQuery(self);
    }

    extern fn wgpuRenderPassEncoderEnd(render_pass_encoder: RenderPassEncoder) void;
    pub inline fn end(self: Self) void {
        return wgpuRenderPassEncoderEnd(self);
    }

    extern fn wgpuRenderPassEncoderSetLabel(render_pass_encoder: RenderPassEncoder, label: StringView) void;
    pub inline fn setLabel(self: Self, label: StringView) void {
        return wgpuRenderPassEncoderSetLabel(self, label);
    }

    extern fn wgpuRenderPassEncoderAddRef(render_pass_encoder: RenderPassEncoder) void;
    pub inline fn addRef(self: Self) void {
        return wgpuRenderPassEncoderAddRef(self);
    }

    extern fn wgpuRenderPassEncoderRelease(render_pass_encoder: RenderPassEncoder) void;
    pub inline fn release(self: Self) void {
        return wgpuRenderPassEncoderRelease(self);
    }
};

pub const RenderPipeline = *opaque {
    pub const Self = @This();

    extern fn wgpuRenderPipelineGetBindGroupLayout(render_pipeline: RenderPipeline, group_index: u32) BindGroupLayout;
    pub inline fn getBindGroupLayout(self: Self, group_index: u32) BindGroupLayout {
        return wgpuRenderPipelineGetBindGroupLayout(self, group_index);
    }

    extern fn wgpuRenderPipelineSetLabel(render_pipeline: RenderPipeline, label: StringView) void;
    pub inline fn setLabel(self: Self, label: StringView) void {
        return wgpuRenderPipelineSetLabel(self, label);
    }

    extern fn wgpuRenderPipelineAddRef(render_pipeline: RenderPipeline) void;
    pub inline fn addRef(self: Self) void {
        return wgpuRenderPipelineAddRef(self);
    }

    extern fn wgpuRenderPipelineRelease(render_pipeline: RenderPipeline) void;
    pub inline fn release(self: Self) void {
        return wgpuRenderPipelineRelease(self);
    }
};

pub const Sampler = *opaque {
    pub const Self = @This();

    extern fn wgpuSamplerSetLabel(sampler: Sampler, label: StringView) void;
    pub inline fn setLabel(self: Self, label: StringView) void {
        return wgpuSamplerSetLabel(self, label);
    }

    extern fn wgpuSamplerAddRef(sampler: Sampler) void;
    pub inline fn addRef(self: Self) void {
        return wgpuSamplerAddRef(self);
    }

    extern fn wgpuSamplerRelease(sampler: Sampler) void;
    pub inline fn release(self: Self) void {
        return wgpuSamplerRelease(self);
    }
};

pub const ShaderModule = *opaque {
    pub const Self = @This();

    extern fn wgpuShaderModuleGetCompilationInfo(shader_module: ShaderModule, callback_info: CompilationInfoCallbackInfo) Future;
    pub inline fn getCompilationInfo(self: Self, callback_info: CompilationInfoCallbackInfo) Future {
        return wgpuShaderModuleGetCompilationInfo(self, callback_info);
    }

    extern fn wgpuShaderModuleSetLabel(shader_module: ShaderModule, label: StringView) void;
    pub inline fn setLabel(self: Self, label: StringView) void {
        return wgpuShaderModuleSetLabel(self, label);
    }

    extern fn wgpuShaderModuleAddRef(shader_module: ShaderModule) void;
    pub inline fn addRef(self: Self) void {
        return wgpuShaderModuleAddRef(self);
    }

    extern fn wgpuShaderModuleRelease(shader_module: ShaderModule) void;
    pub inline fn release(self: Self) void {
        return wgpuShaderModuleRelease(self);
    }
};

// An object used to continuously present image data to the user, see @ref Surfaces for more details.
pub const Surface = *opaque {
    pub const Self = @This();

    extern fn wgpuSurfaceConfigure(surface: Surface, config: *const SurfaceConfiguration) void;
    // Configures parameters for rendering to `surface`.
    // Produces a @ref DeviceError for all content-timeline errors defined by the WebGPU specification.
    //
    // See @ref Surface-Configuration for more details.
    pub inline fn configure(self: Self, config: *const SurfaceConfiguration) void {
        return wgpuSurfaceConfigure(self, config);
    }

    extern fn wgpuSurfaceGetCapabilities(surface: Surface, adapter: Adapter, capabilities: *SurfaceCapabilities) Status;
    // Provides information on how `adapter` is able to use `surface`.
    // See @ref Surface-Capabilities for more details.
    pub inline fn getCapabilities(self: Self, adapter: Adapter, capabilities: *SurfaceCapabilities) Status {
        return wgpuSurfaceGetCapabilities(self, adapter, capabilities);
    }

    extern fn wgpuSurfaceGetCurrentTexture(surface: Surface, surface_texture: *SurfaceTexture) void;
    // Returns the @ref WGPUTexture to render to `surface` this frame along with metadata on the frame.
    // Returns `NULL` and @ref WGPUSurfaceGetCurrentTextureStatus_Error if the surface is not configured.
    //
    // See @ref Surface-Presenting for more details.
    pub inline fn getCurrentTexture(self: Self, surface_texture: *SurfaceTexture) void {
        return wgpuSurfaceGetCurrentTexture(self, surface_texture);
    }

    extern fn wgpuSurfacePresent(surface: Surface) Status;
    // Shows `surface`'s current texture to the user.
    // See @ref Surface-Presenting for more details.
    pub inline fn present(self: Self) Status {
        return wgpuSurfacePresent(self);
    }

    extern fn wgpuSurfaceUnconfigure(surface: Surface) void;
    // Removes the configuration for `surface`.
    // See @ref Surface-Configuration for more details.
    pub inline fn unconfigure(self: Self) void {
        return wgpuSurfaceUnconfigure(self);
    }

    extern fn wgpuSurfaceSetLabel(surface: Surface, label: StringView) void;
    // Modifies the label used to refer to `surface`.
    pub inline fn setLabel(self: Self, label: StringView) void {
        return wgpuSurfaceSetLabel(self, label);
    }

    extern fn wgpuSurfaceAddRef(surface: Surface) void;
    pub inline fn addRef(self: Self) void {
        return wgpuSurfaceAddRef(self);
    }

    extern fn wgpuSurfaceRelease(surface: Surface) void;
    pub inline fn release(self: Self) void {
        return wgpuSurfaceRelease(self);
    }
};

pub const Texture = *opaque {
    pub const Self = @This();

    extern fn wgpuTextureCreateView(texture: Texture, descriptor: ?*const TextureViewDescriptor) TextureView;
    pub inline fn createView(self: Self, descriptor: ?*const TextureViewDescriptor) TextureView {
        return wgpuTextureCreateView(self, descriptor);
    }

    extern fn wgpuTextureSetLabel(texture: Texture, label: StringView) void;
    pub inline fn setLabel(self: Self, label: StringView) void {
        return wgpuTextureSetLabel(self, label);
    }

    extern fn wgpuTextureGetWidth(texture: Texture) u32;
    pub inline fn getWidth(self: Self) u32 {
        return wgpuTextureGetWidth(self);
    }

    extern fn wgpuTextureGetHeight(texture: Texture) u32;
    pub inline fn getHeight(self: Self) u32 {
        return wgpuTextureGetHeight(self);
    }

    extern fn wgpuTextureGetDepthOrArrayLayers(texture: Texture) u32;
    pub inline fn getDepthOrArrayLayers(self: Self) u32 {
        return wgpuTextureGetDepthOrArrayLayers(self);
    }

    extern fn wgpuTextureGetMipLevelCount(texture: Texture) u32;
    pub inline fn getMipLevelCount(self: Self) u32 {
        return wgpuTextureGetMipLevelCount(self);
    }

    extern fn wgpuTextureGetSampleCount(texture: Texture) u32;
    pub inline fn getSampleCount(self: Self) u32 {
        return wgpuTextureGetSampleCount(self);
    }

    extern fn wgpuTextureGetDimension(texture: Texture) TextureDimension;
    pub inline fn getDimension(self: Self) TextureDimension {
        return wgpuTextureGetDimension(self);
    }

    extern fn wgpuTextureGetTextureBindingViewDimension(texture: Texture) TextureViewDimension;
    pub inline fn getTextureBindingViewDimension(self: Self) TextureViewDimension {
        return wgpuTextureGetTextureBindingViewDimension(self);
    }

    extern fn wgpuTextureGetFormat(texture: Texture) TextureFormat;
    pub inline fn getFormat(self: Self) TextureFormat {
        return wgpuTextureGetFormat(self);
    }

    extern fn wgpuTextureGetUsage(texture: Texture) TextureUsage;
    pub inline fn getUsage(self: Self) TextureUsage {
        return wgpuTextureGetUsage(self);
    }

    extern fn wgpuTextureDestroy(texture: Texture) void;
    pub inline fn destroy(self: Self) void {
        return wgpuTextureDestroy(self);
    }

    extern fn wgpuTextureAddRef(texture: Texture) void;
    pub inline fn addRef(self: Self) void {
        return wgpuTextureAddRef(self);
    }

    extern fn wgpuTextureRelease(texture: Texture) void;
    pub inline fn release(self: Self) void {
        return wgpuTextureRelease(self);
    }
};

pub const TextureView = *opaque {
    pub const Self = @This();

    extern fn wgpuTextureViewSetLabel(texture_view: TextureView, label: StringView) void;
    pub inline fn setLabel(self: Self, label: StringView) void {
        return wgpuTextureViewSetLabel(self, label);
    }

    extern fn wgpuTextureViewAddRef(texture_view: TextureView) void;
    pub inline fn addRef(self: Self) void {
        return wgpuTextureViewAddRef(self);
    }

    extern fn wgpuTextureViewRelease(texture_view: TextureView) void;
    pub inline fn release(self: Self) void {
        return wgpuTextureViewRelease(self);
    }
};
