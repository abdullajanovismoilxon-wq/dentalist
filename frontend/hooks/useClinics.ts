"use client";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { clinicService } from "@/services/clinics";

export function useClinics(params?: Record<string, string>) {
  return useQuery({
    queryKey: ["clinics", params],
    queryFn: () => clinicService.list(params),
  });
}

export function useClinic(id: number) {
  return useQuery({
    queryKey: ["clinic", id],
    queryFn: () => clinicService.get(id),
    enabled: !!id,
  });
}

export function useClinicReviews(clinicId: number) {
  return useQuery({
    queryKey: ["clinic-reviews", clinicId],
    queryFn: () => clinicService.getReviews(clinicId),
    enabled: !!clinicId,
  });
}

export function useCreateClinicReview() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ clinicId, ...data }: { clinicId: number; rating: number; comment?: string }) =>
      clinicService.createReview(clinicId, data),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ["clinic-reviews", variables.clinicId] });
      queryClient.invalidateQueries({ queryKey: ["clinic", variables.clinicId] });
    },
  });
}

export function useCheckClinicReview(clinicId: number) {
  return useQuery({
    queryKey: ["clinic-review-check", clinicId],
    queryFn: () => clinicService.checkReview(clinicId),
    enabled: !!clinicId,
  });
}
