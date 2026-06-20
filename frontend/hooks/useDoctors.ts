"use client";
import { useQuery } from "@tanstack/react-query";
import { doctorService } from "@/services/doctors";
import type { TimeSlot } from "@/types";

export function useDoctors(params?: Record<string, string>) {
  return useQuery({
    queryKey: ["doctors", params],
    queryFn: () => doctorService.list(params),
  });
}

export function useNearbyDoctors(params: Record<string, string>) {
  return useQuery({
    queryKey: ["doctors", "nearby", params],
    queryFn: () => doctorService.nearby(params),
    enabled: !!params.lat && !!params.lng,
  });
}

export function useDoctor(id: number) {
  return useQuery({
    queryKey: ["doctor", id],
    queryFn: () => doctorService.getById(id),
    enabled: !!id,
  });
}

export function useAvailableTimes(doctorId: number, date: string) {
  return useQuery<TimeSlot[]>({
    queryKey: ["available-times", doctorId, date],
    queryFn: () => doctorService.getAvailableTimes(doctorId, date),
    enabled: !!doctorId && !!date,
  });
}
