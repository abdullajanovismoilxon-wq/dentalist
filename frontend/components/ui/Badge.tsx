import { cn } from "@/utils";

interface BadgeProps {
  variant?: "default" | "success" | "warning" | "danger" | "info" | "primary";
  children: React.ReactNode;
  className?: string;
}

const variants = {
  default: "bg-bg text-text-secondary",
  success: "bg-green-50 text-success",
  warning: "bg-yellow-50 text-warning",
  danger: "bg-red-50 text-danger",
  info: "bg-primary-light text-primary",
  primary: "bg-primary text-white",
};

export function Badge({ variant = "default", children, className }: BadgeProps) {
  return (
    <span className={cn("inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium", variants[variant], className)}>
      {children}
    </span>
  );
}
