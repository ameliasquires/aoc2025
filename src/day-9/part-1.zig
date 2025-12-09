const std = @import("std");

const point = struct { x: i64, y: i64 };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    
    const path = "input.txt";
    const fp = try std.fs.cwd().openFile(path, .{.mode = std.fs.File.OpenMode.read_only});
    defer fp.close();
    var reader = fp.reader();

    var buffer: [256]u8 = undefined;

    var points = std.ArrayList(point).init(alloc);
    defer points.deinit();

    while(try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        const i = std.mem.indexOf(u8, line, ",").?;

        const p = point{
            .x = try std.fmt.parseInt(i64, line[0..i], 10),
            .y = try std.fmt.parseInt(i64, line[i+1..], 10)
        };

        try points.append(p);
    }

    var largest: u64 = 0;

    for(0..points.items.len) |i| {
        for(i..points.items.len) |z| {
            if(i == z) continue;

            largest = @max(largest, (1 + @abs(points.items[i].x - points.items[z].x)) * (1 + @abs(points.items[i].y - points.items[z].y)));
        }
    }

    std.debug.print("{}\n", .{largest});
}
