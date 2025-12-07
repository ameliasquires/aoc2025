const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    
    const path = "input.txt";
    const fp = try std.fs.cwd().openFile(path, .{.mode = std.fs.File.OpenMode.read_only});
    defer fp.close();
    var reader = fp.reader();

    var buffer: [256]u8 = undefined;

    var beams = std.ArrayList(usize).init(alloc);
    defer beams.deinit();

    var splits: u64 = 0;

    while(try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        if(beams.items.len == 0){
            try beams.append(std.mem.indexOf(u8, line, "S").?);
            continue;
        }

        const ol: usize = beams.items.len;
        for(0..ol) |i| {
            if(line[beams.items[i]] == '^'){
                line[beams.items[i]] = 'i';
                splits += 1;
                try beams.append(beams.items[i] + 1);
                beams.items[i] -= 1;
            } else if(line[beams.items[i]] == 'i'){
                beams.items[i] -= 1;
            }
        }
    }

    std.debug.print("{d}\n", .{splits});
}
