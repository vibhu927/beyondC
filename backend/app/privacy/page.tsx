import Navbar from '@/components/landing/Navbar';
import Footer from '@/components/landing/Footer';

export const metadata = {
  title: 'Privacy Policy – BeyondC',
  description: 'Privacy policy for BeyondC platform.',
};

export default function PrivacyPolicy() {
  return (
    <main className="min-h-screen bg-white">
      <Navbar />
      <section className="mx-auto max-w-3xl px-4 py-20 sm:px-6 lg:px-8 mt-5">
        <h1 className="mb-6 text-center font-jakarta text-4xl font-extrabold text-ink md:text-5xl mt-5">
          Privacy Policy
        </h1>
        <article className="prose prose-neutral max-w-none text-ink">
          <p>
            This Privacy Policy explains how BeyondC ("we", "our", or "us") collects, uses, and
            discloses information when you use our web application.
          </p>
          <h2>Information We Collect</h2>
          <ul>
            <li>Account information you provide during sign‑up (email, name, role).</li>
            <li>Usage data such as pages visited, actions taken, and device information.</li>
            <li>Third‑party data you connect (e.g., Instagram OAuth tokens) when you link external
              services.</li>
          </ul>
          <h2>How We Use Your Information</h2>
          <ul>
            <li>To provide, maintain, and improve the platform.</li>
            <li>To communicate with you about account activity, updates, and support.</li>
            <li>To comply with legal obligations and safeguard the service.</li>
          </ul>
          <h2>Data Retention & Deletion</h2>
          <p>
            We retain your personal data for as long as you maintain an active account or as required
            by law. You may request deletion of your data via the account settings or by contacting
            support.
          </p>
          <h2>Security</h2>
          <p>
            We implement reasonable administrative, technical, and physical safeguards to protect your
            data. However, no method is 100% secure, and we cannot guarantee absolute protection.
          </p>
          <h2>Changes to This Policy</h2>
          <p>
            We may update this Privacy Policy from time to time. Changes will be posted on this page
            with an updated revision date.
          </p>
          <h2>Contact</h2>
          <p>
            If you have any questions about this policy, please contact us at beyond.content01@gmail.com.
          </p>
        </article>
      </section>
      <Footer />
    </main>
  );
}
