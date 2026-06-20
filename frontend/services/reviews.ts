import api from "./api";
import type { Review } from "@/types";

export const reviewService = {
  async getDoctorReviews(doctorId: number): Promise<Review[]> {
    const res = await api.get(`/reviews/doctor/${doctorId}/`);
    return res.data.results || res.data;
  },

  async createReview(data: { doctor: number; rating: number; comment?: string }): Promise<Review> {
    const res = await api.post("/reviews/create/", data);
    return res.data;
  },

  async checkReview(doctorId: number): Promise<{ has_reviewed: boolean }> {
    const res = await api.get(`/reviews/check/${doctorId}/`);
    return res.data;
  },
};
