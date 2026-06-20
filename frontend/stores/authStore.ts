import { create } from "zustand";
import type { User } from "@/types";

const isBrowser = typeof window !== "undefined";

function getStorageItem(key: string) {
  if (!isBrowser) return null;
  try { return JSON.parse(localStorage.getItem(key) || "null"); } catch { return null; }
}

function setStorageItem(key: string, value: unknown) {
  if (!isBrowser) return;
  try { localStorage.setItem(key, JSON.stringify(value)); } catch {}
}

function removeStorageItem(key: string) {
  if (!isBrowser) return;
  try { localStorage.removeItem(key); } catch {}
}

interface AuthState {
  user: User | null;
  tokens: { access: string; refresh: string } | null;
  setAuth: (user: User, tokens: { access: string; refresh: string }) => void;
  setTokens: (tokens: { access: string; refresh: string }) => void;
  setUser: (user: User) => void;
  logout: () => void;
  isAuthenticated: () => boolean;
  isDoctor: () => boolean;
  isPatient: () => boolean;
}

export const useAuthStore = create<AuthState>((set, get) => ({
  user: getStorageItem("auth_user"),
  tokens: getStorageItem("auth_tokens"),

  setAuth: (user, tokens) => {
    setStorageItem("auth_user", user);
    setStorageItem("auth_tokens", tokens);
    set({ user, tokens });
  },

  setTokens: (tokens) => {
    setStorageItem("auth_tokens", tokens);
    set({ tokens });
  },

  setUser: (user) => {
    setStorageItem("auth_user", user);
    set({ user });
  },

  logout: () => {
    removeStorageItem("auth_user");
    removeStorageItem("auth_tokens");
    set({ user: null, tokens: null });
  },

  isAuthenticated: () => !!get().tokens,
  isDoctor: () => get().user?.role === "doctor",
  isPatient: () => get().user?.role === "patient",
}));
