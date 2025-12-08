const std = @import("std");

const point = struct { x: i64, y: i64, z: i64 };
const dist = struct { dist: f64, a: usize, b: usize };

pub fn distance(a: point, b: point) f64 {
    const x = std.math.pow(i64, a.x - b.x, 2);
    const y = std.math.pow(i64, a.y - b.y, 2);
    const z = std.math.pow(i64, a.z - b.z, 2);

    return @abs(@sqrt(@as(f64, @floatFromInt(x + y + z))));
}

pub fn asc_dist(_: void, a: dist, b:dist) bool {
    return a.dist < b.dist;
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

    var points = std.ArrayList(point).init(alloc);
    defer points.deinit();

    while(try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        const v1 = std.mem.indexOf(u8, line, ",").?;
        const v2 = std.mem.indexOf(u8, line[v1+1..], ",").? + v1+1;

        const p = point{
            .x = try std.fmt.parseInt(i64, line[0..v1], 10),
            .y = try std.fmt.parseInt(i64, line[v1+1..v2], 10),
            .z = try std.fmt.parseInt(i64, line[v2+1..], 10),
        };

        try points.append(p);
    }

    var dists = std.ArrayList(dist).init(alloc);
    defer dists.deinit();
    var used = std.AutoHashMap(usize, bool).init(alloc);
    defer used.deinit();

    for(0..points.items.len) |a| {
        for(a..points.items.len) |b| {
            if(a == b) continue;
            const d = distance(points.items[a], points.items[b]);

            try dists.append(dist{.dist = d, .a = a, .b = b});
        }
    }    

    std.mem.sort(dist, dists.items, {}, asc_dist);
    for(dists.items) |o| {
        try used.put(o.a, true);
        try used.put(o.b, true);

        if(used.count() >= points.items.len) {
            std.debug.print("{}\n", .{points.items[o.a].x * points.items[o.b].x});
            break;
        }

    }

}
