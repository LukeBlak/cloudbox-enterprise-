import axios from "axios";

const apiBaseUrl = import.meta.env.VITE_API_URL || "https://4547pw0gbc.execute-api.us-east-1.amazonaws.com/dev";

const api = axios.create({
  baseURL: apiBaseUrl
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");
  const apiKey = import.meta.env.VITE_API_KEY || "IAFyAIys1P4KcsxktSH2q1knQEs4B5aMmsiEQ35h";

  if (token) {
    config.headers.Authorization = token;
  }

  if (apiKey) {
    config.headers["x-api-key"] = apiKey;
  }

  return config;
});

export default api;
