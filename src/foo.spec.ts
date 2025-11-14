import { describe, it, expect } from "vitest";
import { foo } from "./foo";

describe("foo", () => {
  it("should return 'foo'", () => {
    expect(foo()).toBe("foo");
  });
  it("should not be a thing", () => {
    expect(foo()).not.toBe("thing");
  });
});
