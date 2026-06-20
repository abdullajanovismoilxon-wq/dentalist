"use client";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useRouter } from "next/navigation";
import { authService } from "@/services/auth";
import { useAuthStore } from "@/stores/authStore";
import type { User } from "@/types";

export function useLogin() {
  const setAuth = useAuthStore((s) => s.setAuth);
  const router = useRouter();

  return useMutation({
    mutationFn: ({ phone, password }: { phone: string; password: string }) =>
      authService.login(phone, password),
    onSuccess: (data) => {
      const store = useAuthStore.getState();
      store.setAuth(data.user, { access: data.access, refresh: data.refresh });
      router.push(data.user.role === "doctor" ? "/dashboard" : "/profile");
    },
  });
}

export function useRegister() {
  const setAuth = useAuthStore((s) => s.setAuth);
  const router = useRouter();

  return useMutation({
    mutationFn: (data: Record<string, unknown>) => authService.register(data),
    onSuccess: (data) => {
      setAuth(data.user, { access: data.access, refresh: data.refresh });
      router.push("/profile");
    },
  });
}

export function useRegisterDoctor() {
  const setAuth = useAuthStore((s) => s.setAuth);
  const router = useRouter();

  return useMutation({
    mutationFn: (data: Record<string, unknown>) => authService.registerDoctor(data),
    onSuccess: (data) => {
      setAuth(data.user, { access: data.access, refresh: data.refresh });
      router.push("/profile");
    },
  });
}

export function useProfile() {
  return useQuery({
    queryKey: ["profile"],
    queryFn: authService.getProfile,
    enabled: !!useAuthStore.getState().tokens,
  });
}

export function useUpdateProfile() {
  const setUser = useAuthStore((s) => s.setUser);
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: Partial<User> | FormData) => authService.updateProfile(data),
    onSuccess: (user) => {
      setUser(user);
      queryClient.invalidateQueries({ queryKey: ["profile"] });
    },
  });
}

export function useLogout() {
  const logout = useAuthStore((s) => s.logout);
  const router = useRouter();

  return () => {
    logout();
    router.push("/");
  };
}
