import { describe, it, expect } from "vitest";
import { bar } from "./bar";

describe("bar", () => {
  it("should return 'bar'", () => {
    expect(bar()).toBe("bar");
  });
  it("should be something", () => {
    expect(bar()).toBeDefined();
  });
});
