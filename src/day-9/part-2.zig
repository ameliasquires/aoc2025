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

            const vol = (1 + @abs(points.items[i].x - points.items[z].x)) * (1 + @abs(points.items[i].y - points.items[z].y));
            if(vol > largest) {
                const len: i64 = @intCast(@abs(points.items[i].x - points.items[z].x));
                const high: i64 = @intCast(@abs(points.items[i].y - points.items[z].y));

                const a: i64 = @min(points.items[i].x, points.items[z].x);
                const b: i64 = a + len;
                const c: i64 = @min(points.items[i].y, points.items[z].y);
                const d: i64 = c + high;

                var pass: bool = true;
                //check if any line intersects with this box, so glad this worked
                for(0..points.items.len, 1..points.items.len + 1) |o,s| {
                    const item1 = points.items[o];
                    const item2 = if(points.items.len > s) points.items[s] else points.items[0];
                    const verticle = item1.x == item2.x;

                    if(verticle and (a < item1.x and item1.x < b) and !(item1.y >= d and item2.y >= d or item1.y <= c and item2.y <= c)){
                        pass = false;
                        break;
                    } else if(!verticle and (c < item1.y and item1.y < d) and !(item1.x >= b and item2.x >= b or item1.x <= a and item2.x <= a)){
                        pass = false;
                        break;
                    }
                }
                if(pass) largest = vol;
            }
        }
    }

    std.debug.print("{}\n", .{largest});
}
