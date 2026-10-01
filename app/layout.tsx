import type { Metadata, ReactNode } from "react";
import "./globals.css";
export const metadata: Metadata = { title: "Commonplace — Project Board", description: "A calm, collaborative space for good work." };
export default function RootLayout({ children }: Readonly<{ children: ReactNode }>) { return <html lang="en"><body>{children}</body></html>; }

