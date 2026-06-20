import api from "./api";
import type { SearchResults } from "@/types";

export const searchService = {
  async global(query: string): Promise<SearchResults> {
    const res = await api.get("/search/", { params: { q: query } });
    return res.data;
  },
};
