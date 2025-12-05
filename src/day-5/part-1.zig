const std = @import("std");

const range = struct { low: u64, high: u64 };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    
    const path = "input.txt";
    const fp = try std.fs.cwd().openFile(path, .{.mode = std.fs.File.OpenMode.read_only});
    defer fp.close();
    var reader = fp.reader();

    var list = std.ArrayList(range).init(alloc);
    defer list.deinit();

    var buffer: [256]u8 = undefined;

    var fresh: u64 = 0;

    while(try reader.readUntilDelimiterOrEof(&buffer, '\n')) |line| {
        if(line.len == 0) continue;

        if(std.mem.indexOf(u8, line, "-")) |ind| {
            const low: u64 = try std.fmt.parseInt(u64, line[0 .. ind], 10);
            const high: u64 = try std.fmt.parseInt(u64, line[ind + 1 ..], 10);

            try list.append(.{.high = high, .low = low});
        } else {
            const n: u64 = try std.fmt.parseInt(u64, line, 10);

            for(list.items) |r| {
                if(r.low <= n and n <= r.high){
                    fresh += 1;
                    break;
                }
            }
        }
    }

    std.debug.print("{d}\n", .{fresh});
}
