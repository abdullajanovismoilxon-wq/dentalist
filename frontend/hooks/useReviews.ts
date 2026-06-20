"use client";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { reviewService } from "@/services/reviews";

export function useDoctorReviews(doctorId: number) {
  return useQuery({
    queryKey: ["doctor-reviews", doctorId],
    queryFn: () => reviewService.getDoctorReviews(doctorId),
    enabled: !!doctorId,
  });
}

export function useCreateReview() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (data: { doctor: number; rating: number; comment?: string }) =>
      reviewService.createReview(data),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ["doctor-reviews", variables.doctor] });
      queryClient.invalidateQueries({ queryKey: ["doctor", variables.doctor] });
    },
  });
}

export function useCheckReview(doctorId: number) {
  return useQuery({
    queryKey: ["doctor-review-check", doctorId],
    queryFn: () => reviewService.checkReview(doctorId),
    enabled: !!doctorId,
  });
}
