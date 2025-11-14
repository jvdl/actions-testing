import { defineConfig } from "vite";
import viteTsconfigPaths from "vite-tsconfig-paths";
import { defaultExclude } from "vitest/config";

export default defineConfig({
  plugins: [
    viteTsconfigPaths(),
  ],

  test: {
    environment: "jsdom",
    include: ["**/*.spec.?(c|m)[jt]s?(x)"],
    exclude: [...defaultExclude],
    reporters: ["default", ["junit", { suiteName: "vitest", classnameTemplate: "filename:{filename} - filepath:{filepath}" }]],
    outputFile: "../test-results/ui-vitest-junit.xml", // ../ because vitest runs from /src
  },
});
