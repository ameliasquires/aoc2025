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
    var highest: f64 = 0;
    const dists_max = 1000;

    for(0..points.items.len) |a| {
        for(a..points.items.len) |b| {
            if(a == b) continue;
            const d = distance(points.items[a], points.items[b]);
            if(dists.items.len < dists_max) {
                try dists.append(dist{.dist = d, .a = a, .b = b});
                if(d > highest) highest = d;
                continue;
            }

            try dists.append(dist{.dist = d, .a = a, .b = b});
            std.mem.sort(dist, dists.items, {}, asc_dist);
            _ = dists.pop(); 
        }
    }

    var used = std.AutoHashMap(point, bool).init(alloc);
    defer used.deinit();

    var circuits = std.ArrayList(u64).init(alloc);
    defer circuits.deinit();

    for(0..dists.items.len) |i| {
        if(used.contains(points.items[dists.items[i].a]) or used.contains(points.items[dists.items[i].b])) continue;
        var contains = std.AutoHashMap(point, bool).init(alloc);
        defer contains.deinit();

        try contains.put(points.items[dists.items[i].a], true);
        try contains.put(points.items[dists.items[i].b], true);

        var last_count: usize = 0;
        while(last_count != contains.count()){
            last_count = contains.count();
            for(0..dists.items.len) |z| {
                if(i == z) continue;

                if(contains.contains(points.items[dists.items[z].a]) or contains.contains(points.items[dists.items[z].b])){
                    try contains.put(points.items[dists.items[z].a], true);
                    try contains.put(points.items[dists.items[z].b], true);
                }
            }
        }

        var it = contains.keyIterator();
        while(it.next()) |o| try used.put(o.*, true);
        try circuits.append(contains.count());
    }

    std.mem.sort(u64, circuits.items, {}, std.sort.desc(u64));
    var m: u64 = 1;
    for(0..3) |i| m *= circuits.items[i];
    
    std.debug.print("{}\n", .{m});
}
