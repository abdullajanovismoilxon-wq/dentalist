import api from "./api";
import type { Favorite } from "@/types";

export const favoriteService = {
  async list(): Promise<Favorite[]> {
    const res = await api.get("/favorites/");
    return res.data.results || res.data;
  },

  async add(doctorId: number): Promise<Favorite> {
    const res = await api.post("/favorites/add/", { doctor: doctorId });
    return res.data;
  },

  async remove(doctorId: number): Promise<void> {
    await api.delete(`/favorites/remove/${doctorId}/`);
  },
};
