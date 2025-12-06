const std = @import("std");

const problem = struct {n: std.ArrayList(u64), mult: bool};

pub fn op(alloc: std.mem.Allocator, list: *std.ArrayList(problem), chunk: usize, count: u64, slice: []u8) !void {
    if(slice[0] == '+' or slice[0] == '*'){
        list.items[chunk].mult = slice[0] == '*';
    } else {
        const n: u64 = try std.fmt.parseInt(u64, slice, 10);

        if(count == 0) {
            var l = std.ArrayList(u64).init(alloc);
            try l.append(n);
            try list.append(problem{.n = l, .mult = false});
        }
        else try list.items[chunk].n.append(n);
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    
    const path = "input.txt";
    const fp = try std.fs.cwd().openFile(path, .{.mode = std.fs.File.OpenMode.read_only});
    defer fp.close();
    var reader = fp.reader();

    var buffer: [8000]u8 = undefined;

    var list = std.ArrayList(problem).init(alloc);
    defer list.deinit();
    defer for(list.items) |v| v.n.deinit();

    var count: u64 = 0;

    while(try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| : (count += 1) {
        var i: usize = 0;
        var chunk: usize = 0;
        while(i < line.len){
            while(i < line.len and line[i] == ' ') : (i += 1){}

            if(std.mem.indexOf(u8, line[i..], " ")) |ind| {
                try op(alloc, &list, chunk, count, line[i..i + ind]);
                i = i + ind;
                chunk += 1;
            } else {
                if(line[i..].len != 0){
                    try op(alloc, &list, chunk, count, line[i..]); 
                }
                break;
            }
        }
    }

    var total: u64 = 0;

    for(list.items) |v| {
        var n: u64 = 0;
        if(v.mult){
            n = 1;
            for(v.n.items) |a| n *= a;
        } else {
            for(v.n.items) |a| n += a;
        }
        total += n;
    }

    std.debug.print("{d}\n", .{total});
}
