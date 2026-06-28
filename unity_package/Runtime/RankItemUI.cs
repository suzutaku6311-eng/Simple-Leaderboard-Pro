using UnityEngine;
using UnityEngine.UI;

namespace SimpleLeaderboardPro
{
    public class RankItemUI : MonoBehaviour
    {
        [Header("UI References")]
        public Text rankText;
        public Text nameText;
        public Text scoreText;
        public Image backgroundImage;

        [Header("Pop Colors")]
        public Color goldColor = new Color(1f, 0.84f, 0f, 0.9f);
        public Color silverColor = new Color(0.75f, 0.78f, 0.8f, 0.9f);
        public Color bronzeColor = new Color(0.8f, 0.5f, 0.2f, 0.9f);
        public Color defaultColor1 = new Color(0.95f, 0.95f, 0.98f, 0.9f);
        public Color defaultColor2 = new Color(0.88f, 0.9f, 0.95f, 0.9f);

        public void Setup(int rank, string playerName, int score)
        {
            if (rankText != null) rankText.text = GetRankString(rank);
            if (nameText != null) nameText.text = playerName;
            if (scoreText != null) scoreText.text = score.ToString("N0");

            if (backgroundImage != null)
            {
                if (rank == 1) backgroundImage.color = goldColor;
                else if (rank == 2) backgroundImage.color = silverColor;
                else if (rank == 3) backgroundImage.color = bronzeColor;
                else backgroundImage.color = (rank % 2 == 0) ? defaultColor1 : defaultColor2;
            }

            // テキストカラーの調整
            Color textColor = (rank <= 3) ? Color.white : new Color(0.2f, 0.2f, 0.3f);
            if (rankText != null) rankText.color = textColor;
            if (nameText != null) nameText.color = textColor;
            if (scoreText != null) scoreText.color = textColor;
        }

        private string GetRankString(int rank)
        {
            switch (rank)
            {
                case 1: return "🥇 1";
                case 2: return "🥈 2";
                case 3: return "🥉 3";
                default: return rank.ToString();
            }
        }
    }
}
