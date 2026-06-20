import axios from "axios";

const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000/api",
  headers: {
    "Content-Type": "application/json",
  },
});

api.interceptors.request.use((config) => {
  if (typeof window !== "undefined") {
    if (config.url?.includes("/login/") || config.url?.includes("/register/")) {
      return config;
    }
    const tokens = localStorage.getItem("auth_tokens");
    if (tokens) {
      const { access } = JSON.parse(tokens);
      config.headers.Authorization = `Bearer ${access}`;
    }
  }
  return config;
});

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (typeof window === "undefined") return Promise.reject(error);
    const originalRequest = error.config;
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      try {
        const tokens = localStorage.getItem("auth_tokens");
        if (tokens) {
          const { refresh } = JSON.parse(tokens);
          const res = await axios.post(
            `${api.defaults.baseURL}/users/refresh/`,
            { refresh }
          );
          const newTokens = { ...JSON.parse(tokens), access: res.data.access };
          localStorage.setItem("auth_tokens", JSON.stringify(newTokens));
          originalRequest.headers.Authorization = `Bearer ${res.data.access}`;
          return api(originalRequest);
        }
      } catch {
        localStorage.removeItem("auth_tokens");
        localStorage.removeItem("auth_user");
        window.location.href = "/auth/login";
      }
    }
    return Promise.reject(error);
  }
);

export default api;
