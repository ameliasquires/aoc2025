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

    var beams = std.AutoHashMap(usize, u64).init(alloc);
    defer beams.deinit();

    while(try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        if(beams.count() == 0){
            try beams.put(std.mem.indexOf(u8, line, "S").?, 1);
            continue;
        }

        for(line, 0..) |l, i| {
            if(l == '^' and beams.contains(i)){
                const val = beams.get(i).?;
                if(beams.contains(i + 1)) { try beams.put(i + 1, beams.get(i + 1).? + val); }
                else try beams.put(i + 1, val);
                if(beams.contains(i - 1)) { try beams.put(i - 1, beams.get(i - 1).? + val); }
                else try beams.put(i - 1, val);

                try beams.put(i, 0);
            }
        }        
    }

    var k = beams.iterator();
    var timelines: u64 = 0;
    while(k.next()) |o| {
        timelines += o.value_ptr.*;
    }

    std.debug.print("{d}\n", .{timelines});
}
