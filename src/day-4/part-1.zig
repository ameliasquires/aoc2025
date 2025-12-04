const std = @import("std");

pub fn adj(list: std.ArrayList([]u8), x: usize, y: usize) u8 {
    var count: u8 = 0;

    if(y > 0 and list.items[y - 1][x] == '@') count += 1;
    if(y < list.items.len - 1 and list.items[y + 1][x] == '@') count += 1;
    if(x > 0 and list.items[y][x - 1] == '@') count += 1;
    if(x < list.items[0].len - 1 and list.items[y][x + 1] == '@') count += 1;

    if(y > 0 and x > 0 and list.items[y - 1][x - 1] == '@') count += 1;
    if(y < list.items.len - 1 and x > 0 and list.items[y + 1][x - 1] == '@') count += 1;
    if(y > 0 and x < list.items[0].len - 1 and list.items[y - 1][x + 1] == '@') count += 1;
    if(y < list.items.len - 1 and x < list.items[0].len - 1 and list.items[y + 1][x + 1] == '@') count += 1;

    return count;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    
    const path = "input.txt";
    const fp = try std.fs.cwd().openFile(path, .{.mode = std.fs.File.OpenMode.read_only});
    defer fp.close();
    var reader = fp.reader();

    var buffer: [256]u8 = undefined;
    var list = std.ArrayList([]u8).init(alloc);
    defer list.deinit();
    defer for(list.items) |i| alloc.free(i);

    while(try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        var linec = try alloc.alloc(u8, 256);

        @memset(linec, 0);
        @memcpy(linec[0..line.len], line);
        try list.append(linec);
    }

    var count: u64 = 0;

    for(0..list.items.len) |y| {
        for(0..list.items[0].len) |x| {
            if(list.items[y][x] == '@' and adj(list, x, y) < 4) {
                count += 1;
            }
        }
    }

    std.debug.print("{d}\n", .{count});
}
