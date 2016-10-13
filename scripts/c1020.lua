--船見結衣
function c1020.initial_effect(c)

	-- tohand
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1020, 0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	--e1:SetCountLimit(1, 1020) -- 1ターンに1度しか効果を使用できないようにする
	e1:SetCountLimit(1) -- 1ターンに1度しか効果を使用できないようにする
	e1:SetTarget(c1020.target)
	e1:SetOperation(c1020.operation)
	c:RegisterEffect(e1)

end

-- <誰がなにを対象に発動するのか>
function c1020.target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	if chk == 0 then return Duel.IsExistingTarget(Card.IsAbleToHand, tp, LOCATION_ONFIELD, 0, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
	local g = Duel.SelectTarget(tp, Card.IsAbleToHand, tp, LOCATION_ONFIELD, 0, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, 0)
end

-- <効果の内容>
function c1020.operation(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc, nil, REASON_EFFECT)
	end
end
