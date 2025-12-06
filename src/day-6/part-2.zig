const std = @import("std");

const problem = struct {n: []u64, mult: bool};

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
    defer for(list.items) |v| alloc.free(v.n);

    while(try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        if(line[0] == '*' or line[0] == '+'){
            var next_mult: bool = line[0] == '*';
            var i: usize = 1;
            var w: usize = 1;

            while(i < line.len) : ({i += 1; w += 1;}) {
                if(line[i] != ' '){
                    var l = try alloc.alloc(u64, w - 1);
                    @memset(l[0..], 0);
                    try list.append(problem{.n = l, .mult = next_mult});
                    next_mult = line[i] == '*';
                    w = 0; 
                }
            }
            var l = try alloc.alloc(u64, w);
            @memset(l[0..], 0);
            try list.append(problem{.n = l, .mult = next_mult});
        }
    }

    try fp.seekTo(0);
    while(try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        if(line[0] == '*' or line[0] == '+') break;

        var chunk: usize = 0;
        var count: u64 = 0;

        for(line) |c| {
            if(count >= list.items[chunk].n.len + 1){
                chunk += 1;
                count = 0;
            }

            if(c != ' '){
                list.items[chunk].n[count] *= 10;
                list.items[chunk].n[count] += c - '0';
            }

            count += 1;
            
        }
    }

    var total: u64 = 0;

    for(list.items) |v| {
        var n: u64 = 0;
        if(v.mult){
            n = 1;
            for(v.n) |a| n *= a;
        } else {
            for(v.n) |a| n += a;
        }
        total += n;
    }

    std.debug.print("{d}\n", .{total});
}
