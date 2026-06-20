"use client";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { scheduleService } from "@/services/schedule";

export function useSchedules() {
  return useQuery({
    queryKey: ["doctor-schedules"],
    queryFn: scheduleService.getSchedules,
  });
}

export function useCreateSchedule() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: scheduleService.createSchedule,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["doctor-schedules"] });
    },
  });
}

export function useUpdateSchedule() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, data }: { id: number; data: Partial<Record<string, unknown>> }) =>
      scheduleService.updateSchedule(id, data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["doctor-schedules"] });
    },
  });
}

export function useDeleteSchedule() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: scheduleService.deleteSchedule,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["doctor-schedules"] });
    },
  });
}

export function useToggleSlot() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: scheduleService.toggleSlotBlock,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["available-times"] });
      queryClient.invalidateQueries({ queryKey: ["doctor-slots"] });
    },
  });
}
