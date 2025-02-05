const math = @import("std").math;

const Size = @import("./Types.zig").Size;

pub const Interval = struct {
    min: Size,
    max: Size,

    pub const universe: Interval = .{
        .min = -math.inf(Size),
        .max = math.inf(Size),
    };

    pub const empty: Interval = .{
        .min = math.inf(Size),
        .max = -math.inf(Size),
    };

    pub fn size(self: Interval) Size {
        return self.max - self.min;
    }

    pub fn contains(self: Interval, x: Size) bool {
        return self.min <= x and x <= self.max;
    }

    pub fn surrounds(self: Interval, x: Size) bool {
        return self.min < x and x < self.max;
    }
};
