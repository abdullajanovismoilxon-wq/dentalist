"use client";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { appointmentService } from "@/services/appointments";

export function useMyAppointments() {
  return useQuery({
    queryKey: ["appointments"],
    queryFn: appointmentService.myAppointments,
  });
}

export function useCreateAppointment() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: appointmentService.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["appointments"] });
      queryClient.invalidateQueries({ queryKey: ["available-times"] });
    },
  });
}

export function useCancelAppointment() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: appointmentService.cancel,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["appointments"] }),
  });
}

export function useConfirmAppointment() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: appointmentService.confirm,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["appointments"] }),
  });
}
