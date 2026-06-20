import api from "./api";
import type { Clinic, ClinicReview, PaginatedResponse } from "@/types";

export const clinicService = {
  async list(params?: Record<string, string>): Promise<Clinic[]> {
    const res = await api.get("/clinics/", { params });
    return res.data.results || res.data;
  },

  async get(id: number): Promise<Clinic> {
    const res = await api.get(`/clinics/${id}/`);
    return res.data;
  },

  async getReviews(clinicId: number): Promise<ClinicReview[]> {
    const res = await api.get(`/clinics/${clinicId}/reviews/`);
    return res.data.results || res.data;
  },

  async createReview(clinicId: number, data: { rating: number; comment?: string }): Promise<ClinicReview> {
    const res = await api.post(`/clinics/${clinicId}/reviews/create/`, data);
    return res.data;
  },

  async updateReview(clinicId: number, data: { rating: number; comment?: string }): Promise<ClinicReview> {
    const res = await api.put(`/clinics/${clinicId}/reviews/update/`, data);
    return res.data;
  },

  async checkReview(clinicId: number): Promise<{ has_reviewed: boolean }> {
    const res = await api.get(`/clinics/${clinicId}/reviews/check/`);
    return res.data;
  },

  async uploadGallery(clinicId: number, image: File): Promise<void> {
    const form = new FormData();
    form.append("image", image);
    await api.post(`/clinics/${clinicId}/gallery/upload/`, form, {
      headers: { "Content-Type": "multipart/form-data" },
    });
  },
};
