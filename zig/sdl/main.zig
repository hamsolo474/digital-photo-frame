const c = @cImport({
    @cInclude("SDL2/SDL_image.h");
    @cInclude("SDL2/SDL.h");
});
const assert = @import("std").debug.assert;

pub fn main() !void {
    // const imagePaths: []const u8 = "screenshot1.png";
    // imagePaths[0];
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const screen = c.SDL_CreateWindow("My Game Window",
        c.SDL_WINDOWPOS_UNDEFINED,
        c.SDL_WINDOWPOS_UNDEFINED,
        400, 140,
        c.SDL_WINDOW_FULLSCREEN_DESKTOP) // c.SDL_WINDOW_FULLSCREEN_DESKTOP this will stretch the image to fill the screen in both dims
        orelse
        {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyWindow(screen);

    const renderer = c.SDL_CreateRenderer(screen, -1, 0) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    // const zig_jpg = @embedFile("imgs/one.jpg");
    const zig_jpg: [*c]const u8 = "imgs/one.jpg";
    // const zig_bmp = @embedFile("zig.bmp");
    // const rw = c.SDL_RWFromConstMem(zig_jpg, zig_jpg.len) orelse {
    // // const rw = sdl.SDL_RWFromConstMem(zig_bmp, zig_bmp.len) orelse {
    //     c.SDL_Log("Unable to get RWFromConstMem: %s", c.SDL_GetError());
    //     return error.SDLInitializationFailed;
    // };
    // defer assert(c.SDL_RWclose(rw) == 0);

    const zig_surface = c.IMG_Load(zig_jpg) orelse {
    // const zig_surface = sdl.SDL_LoadBMP_RW(rw, 0) orelse {
        c.SDL_Log("Unable to load bmp: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_FreeSurface(zig_surface);

    const zig_texture = c.SDL_CreateTextureFromSurface(renderer, zig_surface) orelse {
        c.SDL_Log("Unable to create texture from surface: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyTexture(zig_texture);

    var quit = false;
    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    quit = true;
                },
                else => {},
            }
        }

        _ = c.SDL_RenderClear(renderer);
        _ = c.SDL_RenderCopy(renderer, zig_texture, null, null);
        c.SDL_RenderPresent(renderer);

        c.SDL_Delay(17);
    }
}
