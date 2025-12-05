const std = @import("std");

const val = struct { n: u64, open: bool }; 

pub fn asc_val(_: void, a: val, b:val) bool {
    return a.n < b.n;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    
    const path = "input.txt";
    const fp = try std.fs.cwd().openFile(path, .{.mode = std.fs.File.OpenMode.read_only});
    defer fp.close();
    var reader = fp.reader();

    var list = std.ArrayList(val).init(alloc);
    defer list.deinit();

    var buffer: [256]u8 = undefined;

    while(try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {

        if(line.len == 0) break;

        if(std.mem.indexOf(u8, line, "-")) |ind| {
            const low: u64 = try std.fmt.parseInt(u64, line[0 .. ind], 10);
            const high: u64 = try std.fmt.parseInt(u64, line[ind + 1 ..], 10);

            //no clue why this is required, since both are inclusive it should be fine, maybe better sorting would work here but im not certain
            if(low == high){
                continue;
            }

            try list.append(.{.n = high, .open = false});
            try list.append(.{.n = low, .open = true});
        }
    }

    std.mem.sort(val, list.items, {}, asc_val);

    var count: i64 = 0;
    var last_val: u64 = 0;
    var fresh: u64 = 0;
    for(list.items) |v| {
        if(v.open){
            count += 1; 
            if(count == 1) last_val = v.n;
        } else { 
            count -= 1;
            if(count == 0) fresh += v.n - last_val + 1;
        }        
    }

    std.debug.print("{d}\n", .{fresh});
}
