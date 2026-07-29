import Navbar from '@/components/landing/Navbar';
import Footer from '@/components/landing/Footer';

export const metadata = {
  title: 'Terms of Service – BeyondC',
  description: 'Terms of Service for BeyondC platform.',
};

export default function TermsOfService() {
  return (
    <main className="min-h-screen bg-white">
      <Navbar />
      <section className="mx-auto max-w-3xl px-4 py-20 sm:px-6 lg:px-8 mt-5">
        <h1 className="mb-6 text-center font-jakarta text-4xl font-extrabold text-ink md:text-5xl mt-5">
          Terms of Service
        </h1>
        <article className="prose prose-neutral max-w-none text-ink">
          <p>
            These Terms of Service (&quot;Terms&quot;) govern your access to and use of the BeyondC platform.
            By signing up or using the service, you agree to these Terms.
          </p>
          <h2>1. Acceptance of Terms</h2>
          <p>
            By creating an account or accessing BeyondC, you confirm that you have read, understood,
            and agree to be bound by these Terms. If you do not agree, you must not use the service.
          </p>
          <h2>2. User Accounts & Responsibilities</h2>
          <ul>
            <li>You must provide accurate and complete information during registration.</li>
            <li>You are responsible for maintaining the confidentiality of your account credentials.</li>
            <li>You must not impersonate others or provide false information about your brand or reach.</li>
            <li>You may not use the platform for any unlawful or prohibited activity.</li>
          </ul>
          <h2>3. Creator & Brand Conduct</h2>
          <ul>
            <li>Creators must deliver agreed-upon deliverables as outlined in each collaboration.</li>
            <li>Brands must pay agreed amounts promptly through the platform&apos;s payment system.</li>
            <li>Both parties agree to communicate professionally and resolve disputes in good faith.</li>
          </ul>
          <h2>4. Fees & Payments</h2>
          <p>
            Creators pay a collaboration fee when accepting a collab. Brands purchase credit packs to
            send requests and post campaigns. All fees are clearly displayed before any transaction.
          </p>
          <h2>5. Dispute Resolution</h2>
          <p>
            If a dispute arises, both parties agree to first attempt resolution through BeyondC&apos;s
            built-in dispute system. If unresolved, the matter may be escalated through standard legal
            channels.
          </p>
          <h2>6. Limitation of Liability</h2>
          <p>
            BeyondC acts as a platform connecting creators and brands. We are not responsible for
            the quality, delivery, or payment of collaborations beyond the tools provided.
          </p>
          <h2>7. Termination</h2>
          <p>
            We reserve the right to suspend or terminate accounts that violate these Terms or engage
            in fraudulent, abusive, or harmful behavior.
          </p>
          <h2>8. Changes to Terms</h2>
          <p>
            We may update these Terms from time to time. Continued use of the platform after changes
            constitutes acceptance of the updated Terms.
          </p>
          <h2>9. Contact</h2>
          <p>
            For questions about these Terms, please contact us at beyond.content01@gmail.com.
          </p>
        </article>
      </section>
      <Footer />
    </main>
  );
}
