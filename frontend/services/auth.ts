import api from "./api";
import type { AuthResponse, User } from "@/types";

export const authService = {
  async register(data: FormData | Record<string, unknown>): Promise<AuthResponse> {
    const res = await api.post("/users/register/", data);
    return res.data;
  },

  async registerDoctor(data: Record<string, unknown>): Promise<AuthResponse> {
    const res = await api.post("/users/register/doctor/", data);
    return res.data;
  },

  async login(phone: string, password: string): Promise<AuthResponse> {
    const res = await api.post("/users/login/", { phone, password });
    return res.data;
  },

  async getProfile(): Promise<User> {
    const res = await api.get("/users/profile/");
    return res.data;
  },

  async updateProfile(data: FormData | Partial<User>): Promise<User> {
    const res = await api.patch("/users/profile/", data);
    return res.data;
  },

  async refreshToken(refresh: string): Promise<{ access: string }> {
    const res = await api.post("/users/refresh/", { refresh });
    return res.data;
  },
};
