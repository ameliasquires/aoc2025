const std = @import("std");

pub fn repeats(num: u64) !bool {
    var buf: [20]u8 = undefined;

    const str = try std.fmt.bufPrint(&buf, "{}", .{num});
    if(@mod(str.len, 2) == 1) return false; 

    for(0..str.len/2) |find| {
        const bind = find + str.len/2;
        if(str[find] != str[bind]) return false;
        //std.debug.print("{} {c}, {} {c}\n", .{find, str[find], bind, str[bind]});

    }

    return true;
}

pub fn main() !void {
    //var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    //defer gpa.deinit();
    //const alloc = gpa.allocator();
    
    const path = "input.txt";
    const fp = try std.fs.cwd().openFile(path, .{.mode = std.fs.File.OpenMode.read_only});
    defer fp.close();
    var reader = fp.reader();

    var buffer: [256]u8 = undefined;

    var total: u64 = 0;

    while(try reader.readUntilDelimiterOrEof(&buffer, ',')) |l| {
        var line = l;
        if(line[line.len - 1] == '\n') {
            line = line[0 .. line.len - 1];
        }

        if(std.mem.indexOf(u8, line, "-")) |ind| {
            const start = try std.fmt.parseInt(u64, line[0 .. ind], 10);
            const end = try std.fmt.parseInt(u64, line[ind + 1 ..], 10);

            //std.debug.print("{d} - {d}\n", .{start, end});

            for(start .. end + 1) |n| {
                if(try repeats(n)){
                    total += n;
                    //std.debug.print("{}\n", .{n});
                }
            }
        }
    }
    std.debug.print("{d}\n", .{total});
}
